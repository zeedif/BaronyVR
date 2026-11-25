<#
  Installs a locally built BaronyVR runtime into the existing managed install
  (%LOCALAPPDATA%\BaronyVR\Managed) so the normal BaronyVR shortcut runs it.

  - Backs up the active version's Runtime folder, payload.json and active.json
    to %LOCALAPPDATA%\BaronyVR\DevBackup\<timestamp> (outside Managed, so the
    launcher's cleanup never touches it).
  - Copies Runtime\* from this package over the active version's Runtime.
  - Re-hashes the changed files in payload.json and updates active.json, which
    the launcher verifies before every start.

  Undo with Restore-DevBuild.ps1. Close BaronyVR before running.
#>
param([string]$Package = $PSScriptRoot)
$ErrorActionPreference = 'Stop'
$managed = Join-Path $env:LOCALAPPDATA 'BaronyVR\Managed'
$activePath = Join-Path $managed 'active.json'
if (!(Test-Path $activePath)) { throw "BaronyVR is not installed ($activePath not found)." }
if (Get-Process -Name barony,BaronyVR -ErrorAction SilentlyContinue) { throw 'Close Barony / BaronyVR first.' }
$source = Join-Path $Package 'Runtime'
if (!(Test-Path (Join-Path $source 'barony.exe'))) { throw "No Runtime\barony.exe in $Package" }

$active = Get-Content $activePath -Raw | ConvertFrom-Json
$version = [string]$active.active.version
$root = Join-Path $managed "Versions\$version"
$payloadPath = Join-Path $root 'payload.json'

$backup = Join-Path $env:LOCALAPPDATA ("BaronyVR\DevBackup\" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $backup | Out-Null
Copy-Item (Join-Path $root 'Runtime') (Join-Path $backup 'Runtime') -Recurse
Copy-Item $payloadPath (Join-Path $backup 'payload.json')
Copy-Item $activePath (Join-Path $backup 'active.json')
Set-Content (Join-Path $backup 'version.txt') $version
Write-Host "Backup: $backup"

Copy-Item (Join-Path $source '*') (Join-Path $root 'Runtime') -Force

$payload = Get-Content $payloadPath -Raw | ConvertFrom-Json
foreach ($entry in $payload.files) {
    $file = Join-Path $root ([string]$entry.path)
    if (Test-Path $file -PathType Leaf) {
        $entry.sha256 = (Get-FileHash $file -Algorithm SHA256).Hash
    }
}
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($payloadPath, ($payload | ConvertTo-Json -Depth 10), $utf8)
$active.active.manifest_sha256 = (Get-FileHash $payloadPath -Algorithm SHA256).Hash
[IO.File]::WriteAllText($activePath, ($active | ConvertTo-Json -Depth 10), $utf8)

Write-Host "Installed dev build into $version. Start Barony VR with the usual shortcut."
Write-Host "Optional: set BARONYVR_DEBUG_DUMP=2 before launching to capture vr_debug\ images."
