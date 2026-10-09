# Dot-source in a session: . .\tools\env.ps1
$ErrorActionPreference = 'Stop'
$null = & (Join-Path $PSScriptRoot 'Find-Delphi7.ps1')
if ($env:DELPHI7_BIN -and ($env:Path -notlike "*$env:DELPHI7_BIN*")) {
  $env:Path = "$env:DELPHI7_BIN;$env:Path"
}
Write-Host "Delphi session ready: $env:DELPHI7_HOME"
