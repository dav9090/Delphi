#Requires -Version 5.1
<#
.SYNOPSIS
  Locates Borland Delphi 7 (dcc32.exe) and prints/sets paths.
#>
[CmdletBinding()]
param(
  [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Info([string]$Message) {
  if (-not $Quiet) { Write-Host $Message }
}

$candidates = @(
  $env:DELPHI7_HOME,
  'C:\Delphi7',
  'C:\Borland\Delphi7',
  'D:\Delphi7',
  'E:\Delphi7',
  'C:\Program Files (x86)\Borland\Delphi7',
  'C:\Program Files\Borland\Delphi7',
  'C:\Program Files (x86)\Borland\Delphi 7',
  'C:\Program Files\Borland\Delphi 7'
) | Where-Object { $_ -and $_.Trim() -ne '' } | Select-Object -Unique

$homePath = $null
foreach ($root in $candidates) {
  $dcc = Join-Path $root 'Bin\dcc32.exe'
  if (-not (Test-Path $dcc)) {
    $dcc = Join-Path $root 'bin\dcc32.exe'
  }
  if (Test-Path $dcc) {
    $homePath = (Resolve-Path (Split-Path (Split-Path $dcc -Parent) -Parent)).Path
    break
  }
}

if (-not $homePath) {
  # Shallow search only in likely roots (full-disk recurse is too slow).
  $searchRoots = @(
    'C:\Borland',
    'C:\Delphi7',
    'D:\Borland',
    'D:\Delphi7',
    'E:\Borland',
    'E:\Delphi7',
    'C:\Program Files (x86)\Borland',
    'C:\Program Files\Borland'
  ) | Where-Object { Test-Path $_ }
  foreach ($root in $searchRoots) {
    $found = Get-ChildItem -Path $root -Filter 'dcc32.exe' -Recurse -ErrorAction SilentlyContinue -Depth 4 |
      Select-Object -First 1
    if ($found) {
      $homePath = (Resolve-Path (Split-Path (Split-Path $found.FullName -Parent) -Parent)).Path
      break
    }
  }
}

if (-not $homePath) {
  Write-Error @'
Delphi 7 not found (dcc32.exe).
Install licensed Borland Delphi 7 to C:\Delphi7, then re-run Setup-Environment.ps1.
'@
}

$binPath = Join-Path $homePath 'Bin'
if (-not (Test-Path (Join-Path $binPath 'dcc32.exe'))) {
  $binPath = Join-Path $homePath 'bin'
}

$env:DELPHI7_HOME = $homePath
$env:DELPHI7_BIN = $binPath

Write-Info "DELPHI7_HOME=$homePath"
Write-Info "DELPHI7_BIN=$binPath"
Write-Info "dcc32=$(Join-Path $binPath 'dcc32.exe')"

[pscustomobject]@{
  Home = $homePath
  Bin  = $binPath
  Dcc32 = (Join-Path $binPath 'dcc32.exe')
  Ide   = (Join-Path $binPath 'delphi32.exe')
}
