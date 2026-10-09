#Requires -Version 5.1
<#
.SYNOPSIS
  Creates/updates WarehouseDB by running db\*.sql in order via sqlcmd.
.EXAMPLE
  .\tools\Deploy-Database.ps1
  .\tools\Deploy-Database.ps1 -Server .\SQLEXPRESS -User sa -Password secret
#>
[CmdletBinding()]
param(
  [string]$Server = '.',
  [string]$User,
  [string]$Password
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$dbDir = Join-Path $repoRoot 'db'

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
  throw 'sqlcmd not found. Install SQL Server command line utilities or run the scripts from db\ in SSMS.'
}

$baseArgs = @('-S', $Server, '-b', '-f', '65001')
if ($User) {
  $baseArgs += @('-U', $User, '-P', $Password)
} else {
  $baseArgs += '-E'
}

Get-ChildItem -Path $dbDir -Filter '*.sql' | Sort-Object Name | ForEach-Object {
  Write-Host "Running $($_.Name)" -ForegroundColor Cyan
  # -f 65001: scripts are UTF-8, -b: stop on error
  $sqlArgs = $baseArgs + @('-i', $_.FullName)
  & sqlcmd @sqlArgs
  if ($LASTEXITCODE -ne 0) {
    throw "sqlcmd failed on $($_.Name) with exit code $LASTEXITCODE"
  }
}

Write-Host 'WarehouseDB is ready.' -ForegroundColor Green
