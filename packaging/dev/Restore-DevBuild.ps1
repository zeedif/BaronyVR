<#
  Restores the BaronyVR runtime saved by Install-DevBuild.ps1 (latest backup
  by default, or -Backup <folder>).
#>
param([string]$Backup)
$ErrorActionPreference = 'Stop'
$base = Join-Path $env:LOCALAPPDATA 'BaronyVR'
if (!$Backup) {
    $Backup = Get-ChildItem (Join-Path $base 'DevBackup') -Directory | Sort-Object Name | Select-Object -Last 1 -ExpandProperty FullName
}
if (!$Backup -or !(Test-Path (Join-Path $Backup 'version.txt'))) { throw 'No dev backup found.' }
if (Get-Process -Name barony,BaronyVR -ErrorAction SilentlyContinue) { throw 'Close Barony / BaronyVR first.' }
$version = (Get-Content (Join-Path $Backup 'version.txt')).Trim()
$root = Join-Path $base "Managed\Versions\$version"
Remove-Item (Join-Path $root 'Runtime') -Recurse -Force
Copy-Item (Join-Path $Backup 'Runtime') (Join-Path $root 'Runtime') -Recurse
Copy-Item (Join-Path $Backup 'payload.json') (Join-Path $root 'payload.json') -Force
Copy-Item (Join-Path $Backup 'active.json') (Join-Path $base 'Managed\active.json') -Force
Write-Host "Restored $version from $Backup"
