param([string]$Extra = '')
# Starts BaronyVR in the null-HMD harness and walks the menus into a new local game.
$R = 'D:\Juegos\SteamLibrary\steamapps\common\Barony'
Get-Process barony -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
Remove-Item "$R\vr_debug" -Recurse -Force -ErrorAction SilentlyContinue
[IO.File]::WriteAllLines('D:\Workspace\BaronyVR-deps\vrinput.txt', [string[]]@('L stick 0 0', 'R stick 0 0'))
$env:PATH = "D:\Workspace\BaronyVR-deps\build;$R;" + $env:PATH
$env:SteamAppId = '371970'; $env:SteamGameId = '371970'
$env:BARONYVR_DEBUG_DUMP = '1'; $env:BARONYVR_TEST_LOBBY_A = '1'; $env:BARONYVR_TEST_FAKE_HANDS = '1'
$env:BARONYVR_TEST_INPUT = 'D:\Workspace\BaronyVR-deps\vrinput.txt'
$env:BARONYVR_TEST_LEFT_HAND = '-0.20,-0.45,-0.25,0,-30,0'
foreach ($kv in ($Extra -split ';' | ? { $_ })) { $k, $v = $kv.Split('=', 2); Set-Item "env:$k" $v }
$null = Start-Process -FilePath 'D:\Workspace\BaronyVR-deps\build\barony.exe' -WorkingDirectory $R -NoNewWindow `
    -RedirectStandardOutput 'D:\Workspace\BaronyVR-deps\run-stdout.log' -RedirectStandardError 'D:\Workspace\BaronyVR-deps\run-stderr.log' -PassThru
$state = "$R\vr_debug\state.txt"
$deadline = (Get-Date).AddSeconds(60)
while ((Get-Date) -lt $deadline -and ((Get-Content $state -ErrorAction SilentlyContinue).Count -lt 18)) { Start-Sleep 1 }
for ($try = 0; $try -lt 1 -and -not (Test-Path "$R\vr_debug\pose.txt"); $try++) {
    # Title (Space) -> Start game -> Start (right) -> Local adventure; the
    # BARONYVR_TEST_LOBBY_A hook joins, then a simulated A presses "ready".
    & D:\Workspace\BaronyVR-deps\keys.ps1 -Keys space,sleep:2500,space,sleep:1500,right,sleep:400,space,sleep:1500,space,sleep:6000 -Wait 1 | Out-Null
    & D:\Workspace\BaronyVR-deps\vrinput.ps1 -Set "R a 1" -HoldMs 200 -After "R a 0" -Wait 0 | Out-Null
    $deadline = (Get-Date).AddSeconds(25)
    while ((Get-Date) -lt $deadline -and -not (Test-Path "$R\vr_debug\pose.txt")) { Start-Sleep 1 }
}
Start-Sleep 3
'spawn: ' + (Get-Content "$R\vr_debug\pose.txt" -TotalCount 1 -ErrorAction SilentlyContinue)
