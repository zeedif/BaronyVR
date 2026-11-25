<#
  Builds the shareable dev zip: Instalar.cmd + LEEME.txt + BaronyVR\Managed\
  (active.json, Versions\BaronyVR-1.0.2\payload.json and Runtime\*).
  payload.json is re-hashed so the stock 1.0.2 launcher accepts the new files.
  -Build: folder with barony.exe and its DLLs. -Template: any 1.0.2 payload.json.
#>
param(
    [Parameter(Mandatory)] [string]$Build,
    [string]$Template = (Join-Path $env:LOCALAPPDATA 'BaronyVR\Managed\Versions\BaronyVR-1.0.2\payload.json'),
    [string]$Out = (Join-Path (Get-Location) 'BaronyVR-dev.zip')
)
$ErrorActionPreference = 'Stop'
$version = 'BaronyVR-1.0.2'
$stage = Join-Path ([IO.Path]::GetTempPath()) ("baronyvr-zip-" + [guid]::NewGuid())
$root = Join-Path $stage "BaronyVR\Managed\Versions\$version"
New-Item -ItemType Directory (Join-Path $root 'Runtime') -Force | Out-Null
Copy-Item (Join-Path $Build 'barony.exe'), (Join-Path $Build '*.dll') (Join-Path $root 'Runtime')
$payload = Get-Content $Template -Raw | ConvertFrom-Json
foreach ($entry in $payload.files) {
    $file = Join-Path $root ([string]$entry.path)
    if (Test-Path $file -PathType Leaf) { $entry.sha256 = (Get-FileHash $file -Algorithm SHA256).Hash }
}
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $root 'payload.json'), ($payload | ConvertTo-Json -Depth 10), $utf8)
$active = [ordered]@{ active = [ordered]@{ version = $version; sequence = 5; tag = 'v1.0.2';
    manifest_sha256 = (Get-FileHash (Join-Path $root 'payload.json') -Algorithm SHA256).Hash }; previous = $null }
[IO.File]::WriteAllText((Join-Path $stage 'BaronyVR\Managed\active.json'), ($active | ConvertTo-Json -Depth 5), $utf8)
Copy-Item (Join-Path $PSScriptRoot 'Instalar.cmd'), (Join-Path $PSScriptRoot 'LEEME.txt') $stage
Remove-Item $Out -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $Out
Remove-Item $stage -Recurse -Force
Write-Host "Created $Out"
