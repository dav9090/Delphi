#Requires -Version 5.1
<#
.SYNOPSIS
  Installs Delphi 7 Science Edition 2020 from a local pack (7z payloads).
.NOTES
  Default source: G:\Delphi 7 Science Edition 2020
  Target layout matches InstallGUI: C:\Program Files\Borland\Delphi7
#>
[CmdletBinding()]
param(
  [string]$SourceRoot = 'G:\Delphi 7 Science Edition 2020',
  [switch]$SkipFontReg,
  [switch]$SkipExtras
)

$ErrorActionPreference = 'Stop'
$sevenZip = 'C:\Program Files\7-Zip\7z.exe'
if (-not (Test-Path $sevenZip)) { throw "7z not found: $sevenZip" }
if (-not (Test-Path -LiteralPath $SourceRoot)) { throw "Source not found: $SourceRoot" }

$bin = Join-Path $SourceRoot 'Bin'
$logDir = Join-Path $env:TEMP 'Delphi7ScienceInstall'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'install.log'

function Write-Log([string]$Message) {
  $line = '{0:u} {1}' -f (Get-Date), $Message
  Add-Content -LiteralPath $log -Value $line -Encoding UTF8
  Write-Host $Message
}

function Invoke-7zExtract([string]$Archive, [string]$OutDir) {
  if (-not (Test-Path -LiteralPath $Archive)) { throw "Archive missing: $Archive" }
  if ($OutDir -notmatch '^[A-Za-z]:\\?$') {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
  }
  Write-Log "Extract: $Archive -> $OutDir"
  & $sevenZip x -y "-o$OutDir" -- $Archive
  if ($LASTEXITCODE -ne 0) { throw "7z failed ($LASTEXITCODE) for $Archive" }
}

# Admin check
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$identity
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run elevated (Administrator).'
}

Write-Log "Source: $SourceRoot"
Write-Log "Log: $log"

# Step 1 of the GUI pack (SecurityNT.bat / icacls on C:\) is intentionally SKIPPED.

Write-Log '=== Step 2+: Extract Borland.bin -> C:\Program Files ==='
Invoke-7zExtract (Join-Path $bin 'Borland.bin') 'C:\Program Files'

Write-Log '=== Extract Borland Shared.bin -> Common Files ==='
Invoke-7zExtract (Join-Path $bin 'Borland Shared.bin') 'C:\Program Files\Common Files'

Write-Log '=== Extract Inprise.bin -> C:\ ==='
Invoke-7zExtract (Join-Path $bin 'Inprise.bin') 'C:\'

# 32-bit runtime packages: use SysWOW64 on 64-bit Windows
$dllTarget = if (Test-Path 'C:\Windows\SysWOW64') { 'C:\Windows\SysWOW64' } else { 'C:\Windows\System32' }
Write-Log "=== Extract dll.bin -> $dllTarget ==="
Invoke-7zExtract (Join-Path $bin 'dll.bin') $dllTarget

$delphiHome = 'C:\Program Files\Borland\Delphi7'
$delphiBin = Join-Path $delphiHome 'Bin'
$dcc = Join-Path $delphiBin 'dcc32.exe'
if (-not (Test-Path -LiteralPath $dcc)) {
  throw "dcc32.exe not found after extract: $dcc"
}
Write-Log "OK dcc32: $dcc"

# ACL: allow Users modify on Delphi tree (IDE writes config)
Write-Log '=== ACL on Delphi7 tree ==='
& icacls $delphiHome /grant 'Users:(OI)(CI)M' /T /C | Out-Null

# Registry Borland keys (minimal)
Write-Log '=== Registry ==='
$regRoot = 'HKLM:\SOFTWARE\WOW6432Node\Borland\Delphi\7.0'
if (-not (Test-Path 'HKLM:\SOFTWARE\WOW6432Node')) {
  $regRoot = 'HKLM:\SOFTWARE\Borland\Delphi\7.0'
}
New-Item -Path $regRoot -Force | Out-Null
New-ItemProperty -Path $regRoot -Name 'RootDir' -Value $delphiHome -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regRoot -Name 'App' -Value (Join-Path $delphiBin 'delphi32.exe') -PropertyType String -Force | Out-Null

# Shortcuts via installlnk if present
$installLnk = Join-Path $bin 'installlnk.exe'
if (Test-Path -LiteralPath $installLnk) {
  Write-Log '=== installlnk.exe ==='
  Start-Process -FilePath $installLnk -Wait -ErrorAction SilentlyContinue
}

# WinHLP32 (optional help)
$winHlpBat = Join-Path $bin 'WinHLP32\Install.bat'
if ((-not $SkipExtras) -and (Test-Path -LiteralPath $winHlpBat)) {
  Write-Log '=== WinHLP32 Install.bat ==='
  Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', "`"$winHlpBat`"" -WorkingDirectory (Split-Path $winHlpBat) -Wait -ErrorAction SilentlyContinue
}

# Font/codepage reg from pack (affects system fonts — optional)
$fontReg = Join-Path $SourceRoot 'for_Win_Vista_7_8_10.reg'
if ((-not $SkipFontReg) -and (Test-Path -LiteralPath $fontReg)) {
  Write-Log "=== Import font reg: $fontReg ==="
  & reg.exe import $fontReg
}

# User PATH + env
Write-Log '=== PATH / env ==='
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not $userPath) { $userPath = '' }
$parts = @($userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' })
$extra = @(
  $delphiBin,
  (Join-Path $delphiHome 'Projects\Bpl'),
  'C:\Inprise\vbroker\bin'
)
foreach ($p in $extra) {
  if ((Test-Path $p) -and ($parts -notcontains $p)) { $parts += $p }
}
[Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')
[Environment]::SetEnvironmentVariable('DELPHI7_HOME', $delphiHome, 'User')
[Environment]::SetEnvironmentVariable('DELPHI7_BIN', $delphiBin, 'User')
$env:DELPHI7_HOME = $delphiHome
$env:DELPHI7_BIN = $delphiBin
$env:Path = "$delphiBin;$env:Path"

if (-not $SkipExtras) {
  $speedUp = Join-Path $bin 'Delphi7_ext\DelphiSpeedUpV31D7\InstallDelphiSpeedUp7.exe'
  if (Test-Path -LiteralPath $speedUp) {
    Write-Log '=== DelphiSpeedUp (GUI may appear) ==='
    Start-Process -FilePath $speedUp -Wait -ErrorAction SilentlyContinue
  }
  $cn = Join-Path $bin 'Delphi7_ext\CnWizards_1.1.9.991.exe'
  if (Test-Path -LiteralPath $cn) {
    Write-Log '=== CnWizards (GUI may appear) ==='
    Start-Process -FilePath $cn -Wait -ErrorAction SilentlyContinue
  }
}

Write-Log '=== DONE ==='
Write-Log "DELPHI7_HOME=$delphiHome"
Write-Host ''
Write-Host 'Install finished. Open a NEW terminal in the repo root, then:' -ForegroundColor Green
Write-Host '  powershell -ExecutionPolicy Bypass -File .\tools\Setup-Environment.ps1'
Write-Host '  powershell -ExecutionPolicy Bypass -File .\tools\Build-Project.ps1 -Project .\src\Warehouse\Warehouse.dpr'
Write-Host "Log: $log"
