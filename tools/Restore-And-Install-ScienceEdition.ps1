#Requires -Version 5.1
<#
.SYNOPSIS
  1) Remove partial Borland leftover
  2) Restore default Medium integrity on C:\ root (undo installer step 1)
  3) Install Science Edition from step 2 (extract only — NO SecurityNT / NO icacls breakage)
#>
[CmdletBinding()]
param(
  [string]$SourceRoot = 'G:\Delphi 7 Science Edition 2020',
  [switch]$SkipFontReg,
  [switch]$SkipExtras
)

$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$identity
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run elevated (Administrator).'
}

$logDir = Join-Path $env:TEMP 'Delphi7ScienceInstall'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'restore-install.log'
function Write-Log([string]$Message) {
  $line = '{0:u} {1}' -f (Get-Date), $Message
  Add-Content -LiteralPath $log -Value $line -Encoding UTF8
  Write-Host $Message
}

Write-Log '=== 1/3 Remove leftover C:\Program Files\Borland ==='
$borland = 'C:\Program Files\Borland'
if (Test-Path -LiteralPath $borland) {
  cmd /c "rmdir /s /q `"$borland`""
  if (Test-Path -LiteralPath $borland) {
    throw "Failed to remove $borland"
  }
  Write-Log 'Removed.'
} else {
  Write-Log 'Nothing to remove.'
}

Write-Log '=== 2/3 Restore C:\ integrity label (default Medium with OI/CI) ==='
# Installer step 1 used: icacls C:\ /setintegritylevel medium  (often drops OI/CI, can hang)
# Restore typical Windows root label:
& icacls 'C:\' /setintegritylevel '(OI)(CI)Medium'
if ($LASTEXITCODE -ne 0) {
  Write-Log "WARN: icacls restore exit=$LASTEXITCODE"
} else {
  Write-Log 'Integrity restore OK.'
}
Write-Log 'Current C:\ ACL:'
& icacls 'C:\' | ForEach-Object { Write-Log $_ }

Write-Log '=== 3/3 Install from step 2 (extract) ==='
$install = Join-Path $PSScriptRoot 'Install-ScienceEdition.ps1'
$args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $install, '-SourceRoot', $SourceRoot)
if ($SkipFontReg) { $args += '-SkipFontReg' }
if ($SkipExtras) { $args += '-SkipExtras' }
& powershell.exe @args
if ($LASTEXITCODE -ne 0) { throw "Install-ScienceEdition failed: $LASTEXITCODE" }

Write-Log '=== ALL DONE ==='
Write-Host "Log: $log" -ForegroundColor Green
