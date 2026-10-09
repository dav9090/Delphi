#Requires -Version 5.1
# Completes Science Edition after Borland.bin + Shared are already extracted.
# Does NOT touch icacls on C:\.
[CmdletBinding()]
param(
  [string]$SourceRoot = 'G:\Delphi 7 Science Edition 2020'
)

$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run elevated.'
}

$sevenZip = 'C:\Program Files\7-Zip\7z.exe'
$bin = Join-Path $SourceRoot 'Bin'
$log = Join-Path $env:TEMP 'Delphi7ScienceInstall\finish.log'
New-Item -ItemType Directory -Force -Path (Split-Path $log) | Out-Null
function Write-Log([string]$m) {
  Add-Content -LiteralPath $log -Value ('{0:u} {1}' -f (Get-Date), $m) -Encoding UTF8
  Write-Host $m
}
function Invoke-7zExtract([string]$Archive, [string]$OutDir) {
  if ($OutDir -notmatch '^[A-Za-z]:\\?$') {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
  }
  Write-Log "Extract: $Archive -> $OutDir"
  & $sevenZip x -y "-o$OutDir" -- $Archive
  if ($LASTEXITCODE -ne 0) { throw "7z failed $LASTEXITCODE" }
}

if (-not (Test-Path 'C:\Inprise\vbroker\bin')) {
  Invoke-7zExtract (Join-Path $bin 'Inprise.bin') 'C:\'
} else { Write-Log 'Inprise already present' }

$dllTarget = if (Test-Path 'C:\Windows\SysWOW64') { 'C:\Windows\SysWOW64' } else { 'C:\Windows\System32' }
if (-not (Test-Path (Join-Path $dllTarget 'rtl70.bpl'))) {
  Invoke-7zExtract (Join-Path $bin 'dll.bin') $dllTarget
} else { Write-Log 'dll.bin already present' }

$delphiHome = 'C:\Program Files\Borland\Delphi7'
$delphiBin = Join-Path $delphiHome 'Bin'
if (-not (Test-Path (Join-Path $delphiBin 'dcc32.exe'))) { throw 'dcc32 missing' }

Write-Log 'ACL on Bin/Projects only (no full-tree /T)'
# SID S-1-5-32-545 = Builtin Users (locale-independent)
cmd /c "icacls `"$delphiBin`" /grant *S-1-5-32-545:(OI)(CI)M /C" | Out-Null
$proj = Join-Path $delphiHome 'Projects'
if (Test-Path $proj) {
  cmd /c "icacls `"$proj`" /grant *S-1-5-32-545:(OI)(CI)M /T /C" | Out-Null
}

Write-Log 'Registry'
$regRoot = if (Test-Path 'HKLM:\SOFTWARE\WOW6432Node') {
  'HKLM:\SOFTWARE\WOW6432Node\Borland\Delphi\7.0'
} else {
  'HKLM:\SOFTWARE\Borland\Delphi\7.0'
}
New-Item -Path $regRoot -Force | Out-Null
New-ItemProperty -Path $regRoot -Name 'RootDir' -Value $delphiHome -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regRoot -Name 'App' -Value (Join-Path $delphiBin 'delphi32.exe') -PropertyType String -Force | Out-Null

Write-Log 'User PATH / env'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not $userPath) { $userPath = '' }
$parts = @($userPath -split ';' | Where-Object { $_ -and $_.Trim() })
foreach ($p in @($delphiBin, (Join-Path $delphiHome 'Projects\Bpl'), 'C:\Inprise\vbroker\bin')) {
  if ((Test-Path $p) -and ($parts -notcontains $p)) { $parts += $p }
}
[Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')
[Environment]::SetEnvironmentVariable('DELPHI7_HOME', $delphiHome, 'User')
[Environment]::SetEnvironmentVariable('DELPHI7_BIN', $delphiBin, 'User')

$installLnk = Join-Path $bin 'installlnk.exe'
if (Test-Path -LiteralPath $installLnk) {
  Write-Log 'installlnk.exe'
  Start-Process -FilePath $installLnk -Wait -ErrorAction SilentlyContinue
}

Write-Log 'DONE'
Write-Host "dcc32=$delphiBin\dcc32.exe"
