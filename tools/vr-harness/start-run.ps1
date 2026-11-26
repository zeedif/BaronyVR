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
for ($try = 0; $try -lt 2 -and -not (Test-Path "$R\vr_debug\pose.txt"); $try++) {
    & D:\Workspace\BaronyVR-deps\keys.ps1 -Keys space,sleep:2500,"mouse:1700,520","mouse:1720,532",sleep:1500,"mouse:1866,678",sleep:1500,"mouse:1570,409",sleep:6000,"mouse:430,1304" -Wait 1 | Out-Null
    $deadline = (Get-Date).AddSeconds(25)
    while ((Get-Date) -lt $deadline -and -not (Test-Path "$R\vr_debug\pose.txt")) { Start-Sleep 1 }
}
Start-Sleep 3
'spawn: ' + (Get-Content "$R\vr_debug\pose.txt" -TotalCount 1 -ErrorAction SilentlyContinue)
