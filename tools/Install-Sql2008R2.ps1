#Requires -Version 5.1
<#
.SYNOPSIS
  Installs SQL Server 2008 R2 Developer from local ISO (G:\...\*.iso or already mounted).
#>
[CmdletBinding()]
param(
  [string]$IsoPath = '',
  [string]$SaPassword = '',
  [string]$InstanceName = 'MSSQLSERVER'
)

$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run elevated (Administrator).'
}

if (-not $SaPassword) {
  # Random password satisfying SQL Server complexity rules (upper, lower, digit, symbol).
  $SaPassword = 'Sa!' + ([guid]::NewGuid().ToString('N').Substring(0, 12)) + 'Q7'
}

$logDir = Join-Path $env:TEMP 'Sql2008R2Install'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'install.log'
function Write-Log([string]$m) {
  Add-Content $log ('{0:u} {1}' -f (Get-Date), $m) -Encoding UTF8
  Write-Host $m
}

function Find-Sql2008Iso {
  if ($IsoPath -and (Test-Path -LiteralPath $IsoPath)) { return (Resolve-Path -LiteralPath $IsoPath).Path }
  $hits = @()
  foreach ($root in @('G:\', 'D:\', 'E:\', 'F:\')) {
    if (-not (Test-Path $root)) { continue }
    $hits += Get-ChildItem -Path $root -Filter 'ru_sql_server_2008_r2_developer_x86_and_x64_dvd_522741.iso' -Recurse -Depth 4 -ErrorAction SilentlyContinue
    $hits += Get-ChildItem -Path $root -Filter '*sql*2008*r2*developer*.iso' -Recurse -Depth 4 -ErrorAction SilentlyContinue
  }
  $file = $hits | Select-Object -First 1
  if (-not $file) { throw 'SQL 2008 R2 Developer ISO not found under G:/D:/E:/F: (depth 4). Pass -IsoPath.' }
  return $file.FullName
}

Write-Log '=== Ensure .NET Framework 3.5 ==='
try {
  $net35 = Get-WindowsOptionalFeature -Online -FeatureName NetFx3 -ErrorAction Stop
  if ($net35.State -ne 'Enabled') {
    Write-Log 'Enabling NetFx3...'
    Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart | Out-Null
  } else {
    Write-Log 'NetFx3 already enabled'
  }
} catch {
  Write-Log ("NetFx3 check/enable warning: {0}" -f $_.Exception.Message)
}

Write-Log '=== Locate setup.exe ==='
$setup = $null
foreach ($d in @('H','I','J','K','L','D','E','F')) {
  $candidate = "${d}:\setup.exe"
  if ((Test-Path $candidate) -and ((Test-Path "${d}:\x64") -or (Test-Path "${d}:\x86"))) {
    $setup = $candidate
    break
  }
}

if (-not $setup) {
  $iso = Find-Sql2008Iso
  Write-Log "Mounting ISO: $iso"
  Mount-DiskImage -ImagePath $iso | Out-Null
  Start-Sleep -Seconds 2
  $letter = (Get-DiskImage -ImagePath $iso | Get-Volume).DriveLetter
  $setup = "${letter}:\setup.exe"
  if (-not (Test-Path $setup)) { throw "setup.exe missing on ${letter}:" }
}
Write-Log "setup=$setup"

$credFile = Join-Path $logDir 'sa-password.txt'
@"
SQL Server 2008 R2 Developer
Instance: $InstanceName (default)
Auth: Mixed Mode (SQL + Windows)
Login: sa
Password: $SaPassword
Sysadmin: BUILTIN\Administrators + current user
"@ | Set-Content -Path $credFile -Encoding UTF8
Write-Log "Credentials: $credFile"

$config = Join-Path $PSScriptRoot 'sql2008r2\ConfigurationFile.ini'
if (-not (Test-Path $config)) { throw "Config missing: $config" }

$adminUser = $identity.Name
Write-Log "SQLSYSADMINACCOUNTS: BUILTIN\Administrators ; $adminUser"
Write-Log '=== Starting setup (QUIETSIMPLE) — often 20-40+ minutes ==='

$argList = @(
  "/ConfigurationFile=`"$config`"",
  "/INSTANCENAME=$InstanceName",
  "/INSTANCEID=$InstanceName",
  "/SAPWD=`"$SaPassword`"",
  "/SQLSYSADMINACCOUNTS=`"BUILTIN\Administrators`" `"$adminUser`"",
  '/IACCEPTSQLSERVERLICENSETERMS'
)

$p = Start-Process -FilePath $setup -ArgumentList $argList -Wait -PassThru -WorkingDirectory (Split-Path $setup)
Write-Log "setup exit code: $($p.ExitCode)"

if ($p.ExitCode -notin 0, 3010) {
  $bootstrap = 'C:\Program Files\Microsoft SQL Server\100\Setup Bootstrap\Log'
  Write-Log "FAILED. Logs: $bootstrap"
  if (Test-Path $bootstrap) {
    $latest = Get-ChildItem $bootstrap -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
      Write-Log "Latest: $($latest.FullName)"
      Get-ChildItem $latest.FullName -Filter 'Summary*.txt' -ErrorAction SilentlyContinue | ForEach-Object {
        Get-Content $_.FullName -Tail 50 | ForEach-Object { Write-Log $_ }
      }
    }
  }
  throw "SQL setup failed with exit $($p.ExitCode)"
}

Write-Log '=== Services ==='
Get-Service '*SQL*' -ErrorAction SilentlyContinue | ForEach-Object {
  Write-Log ("{0} = {1}" -f $_.Name, $_.Status)
}

Write-Log 'DONE'
Write-Host "SA password file: $credFile" -ForegroundColor Green
if ($p.ExitCode -eq 3010) {
  Write-Host 'Reboot required (exit 3010).' -ForegroundColor Yellow
}
