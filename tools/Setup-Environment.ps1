#Requires -Version 5.1
<#
.SYNOPSIS
  Configures user environment for Delphi 7 and reports helper tools.
#>
[CmdletBinding()]
param(
  [switch]$SkipPathPersist,
  [switch]$InstallHelpers
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

Write-Host '=== Delphi 7 environment setup ===' -ForegroundColor Cyan

$delphi = $null
try {
  $delphi = & (Join-Path $PSScriptRoot 'Find-Delphi7.ps1') -Quiet
} catch {
  Write-Host $_.Exception.Message -ForegroundColor Yellow
  Write-Host ''
  Write-Host 'Manual steps:' -ForegroundColor Yellow
  Write-Host '  1. Install licensed Borland Delphi 7 to C:\Delphi7 (not Program Files).'
  Write-Host '  2. Run installer as Administrator.'
  Write-Host '  3. Re-run this script.'
  Write-Host ''
}

if ($InstallHelpers) {
  Write-Host 'Installing helper packages via winget...' -ForegroundColor Cyan
  $packages = @(
    '7zip.7zip',
    'JRSoftware.InnoSetup',
    'AngusJohnson.ResourceHacker',
    'FreePascal.FreePascalCompiler'
  )
  foreach ($id in $packages) {
    Write-Host "  winget install $id"
    & winget install --id $id -e --accept-package-agreements --accept-source-agreements
  }
}

function Test-Cmd([string]$Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-ToolPath([string[]]$Paths) {
  foreach ($p in $Paths) {
    if (Test-Path $p) { return $p }
  }
  return $null
}

$helperBins = @(
  'C:\Program Files\7-Zip',
  'C:\Program Files (x86)\Inno Setup 6',
  'C:\Program Files\Inno Setup 6',
  (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6'),
  'C:\FPC\3.2.2\bin\i386-win32',
  'C:\FPC\3.2.2\bin\x86_64-win64'
) | Where-Object { Test-Path $_ }
foreach ($bin in $helperBins) {
  if ($env:Path -notlike "*$bin*") {
    $env:Path = "$bin;$env:Path"
  }
}

$sevenZip = Test-ToolPath @('C:\Program Files\7-Zip\7z.exe')
$iscc = Test-ToolPath @(
  'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
  'C:\Program Files\Inno Setup 6\ISCC.exe',
  (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe')
)
$reshack = Test-ToolPath @('C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe', 'C:\Program Files\Resource Hacker\ResourceHacker.exe')
$fpc = Test-ToolPath @(
  'C:\FPC\3.2.2\bin\i386-win32\fpc.exe',
  'C:\FPC\3.2.2\bin\x86_64-win64\fpc.exe'
)

Write-Host ''
Write-Host 'Helper tools:' -ForegroundColor Cyan
@(
  @{ Name = 'git'; Ok = Test-Cmd 'git'; Detail = $null },
  @{ Name = 'winget'; Ok = Test-Cmd 'winget'; Detail = $null },
  @{ Name = '7z'; Ok = [bool]$sevenZip -or (Test-Cmd '7z'); Detail = $sevenZip },
  @{ Name = 'iscc (Inno Setup)'; Ok = [bool]$iscc -or (Test-Cmd 'iscc'); Detail = $iscc },
  @{ Name = 'Resource Hacker'; Ok = [bool]$reshack; Detail = $reshack },
  @{ Name = 'fpc (optional)'; Ok = [bool]$fpc -or (Test-Cmd 'fpc'); Detail = $fpc }
) | ForEach-Object {
  $status = if ($_.Ok) { 'OK' } else { 'missing' }
  if ($_.Detail) {
    Write-Host ('  [{0}] {1} -> {2}' -f $status, $_.Name, $_.Detail)
  } else {
    Write-Host ('  [{0}] {1}' -f $status, $_.Name)
  }
}

if (-not $delphi) {
  Write-Host ''
  Write-Host 'STATUS: Delphi 7 NOT configured' -ForegroundColor Red
  exit 2
}

Write-Host ''
Write-Host "Delphi 7: $($delphi.Home)" -ForegroundColor Green
Write-Host "dcc32:    $($delphi.Dcc32)"

if (-not $SkipPathPersist) {
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (-not $userPath) { $userPath = '' }
  $parts = $userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }
  if ($parts -notcontains $delphi.Bin) {
    $newPath = ($parts + $delphi.Bin) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added to User PATH: $($delphi.Bin)" -ForegroundColor Green
  } else {
    Write-Host 'User PATH already contains Delphi Bin.' -ForegroundColor DarkGray
  }
  [Environment]::SetEnvironmentVariable('DELPHI7_HOME', $delphi.Home, 'User')
  [Environment]::SetEnvironmentVariable('DELPHI7_BIN', $delphi.Bin, 'User')
  Write-Host 'Persisted DELPHI7_HOME and DELPHI7_BIN (User).' -ForegroundColor Green
}

if ($env:Path -notlike "*$($delphi.Bin)*") {
  $env:Path = "$($delphi.Bin);$env:Path"
}

Write-Host ''
Write-Host 'STATUS: ready (open a new terminal for persisted PATH)' -ForegroundColor Green
Write-Host "Repo: $repoRoot"
Write-Host 'Try:  .\tools\Build-Project.ps1 -Project .\src\Warehouse\Warehouse.dpr'
