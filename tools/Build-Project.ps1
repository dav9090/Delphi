#Requires -Version 5.1
<#
.SYNOPSIS
  Builds a Delphi 7 .dpr with dcc32.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Project,

  [string]$OutDir,
  [string[]]$UnitPath = @(),
  [switch]$Rebuild
)

$ErrorActionPreference = 'Stop'
$delphi = & (Join-Path $PSScriptRoot 'Find-Delphi7.ps1') -Quiet
$projectPath = (Resolve-Path $Project).Path
$projectDir = Split-Path $projectPath -Parent

if (-not $OutDir) {
  $OutDir = Join-Path $projectDir 'bin'
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$dcc = $delphi.Dcc32
$projectFile = Split-Path $projectPath -Leaf
$dccArgs = @()
if ($Rebuild) { $dccArgs += '-B' }
$dccArgs += '-Q'
$dccArgs += "-E$OutDir"
$dccArgs += "-N$OutDir"

$unitPaths = @('.') + ($UnitPath | ForEach-Object { $_.TrimEnd('\') })
$joined = $unitPaths -join ';'
$dccArgs += "-U$joined"
$dccArgs += "-I$joined"
$dccArgs += $projectFile

Write-Host "Compiling with: $dcc" -ForegroundColor Cyan
Write-Host ("cwd=$projectDir; " + ($dccArgs -join ' '))

Push-Location $projectDir
try {
  & $dcc @dccArgs
  if ($LASTEXITCODE -ne 0) {
    throw "dcc32 failed with exit code $LASTEXITCODE"
  }
} finally {
  Pop-Location
}

$iniSrc = Join-Path $projectDir 'Warehouse.ini'
if (Test-Path $iniSrc) {
  Copy-Item -Force $iniSrc (Join-Path $OutDir 'Warehouse.ini')
}

Write-Host "OK -> $OutDir" -ForegroundColor Green
