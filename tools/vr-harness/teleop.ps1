<#
  Drive BaronyVR's simulated VR controllers from the keyboard (works from any
  focused window) and record the session for replay.
    W/S/A/D       left stick (move)          Left/Right arrows  right stick (turn)
    Up arrow      right stick up (equip)     Down arrow         right stick down (quick turn)
    Space         right trigger              E                  A (use)
    R             B (spell)                  Q / F              left / right grip
    T             left trigger (defend)      X                  X (inventory)
    Esc           stop and save
  Recording: D:\Workspace\BaronyVR-deps\recording.txt  (ms<TAB>command lines)
#>
$ErrorActionPreference = 'Stop'
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class Ks { [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vk); }
'@
$inputFile = 'D:\Workspace\BaronyVR-deps\vrinput.txt'
$recordFile = 'D:\Workspace\BaronyVR-deps\recording.txt'
function Down([int]$vk) { ([Ks]::GetAsyncKeyState($vk) -band 0x8000) -ne 0 }
$record = New-Object System.Collections.Generic.List[string]
$clock = [Diagnostics.Stopwatch]::StartNew()
$last = @{}
Write-Host 'Teleop activo. WASD mover, flechas girar, Espacio gatillo, E usar, Esc para terminar.'
while (-not (Down 0x1B)) {
    $lx = (Down 0x44) - (Down 0x41)     # D - A
    $ly = (Down 0x57) - (Down 0x53)     # W - S
    $rx = (Down 0x27) - (Down 0x25)     # Right - Left
    $ry = (Down 0x26) - (Down 0x28)     # Up - Down
    $state = [ordered]@{
        'L stick'   = ('{0} {1}' -f ([double]$lx * 0.85), ([double]$ly * 0.85))
        'R stick'   = ('{0} {1}' -f ([double]$rx * 0.9), ([double]$ry * 0.9))
        'R trigger' = [string][int](Down 0x20)
        'L trigger' = [string][int](Down 0x54)
        'R a'       = [string][int](Down 0x45)
        'R b'       = [string][int](Down 0x52)
        'L x'       = [string][int](Down 0x58)
        'L grip'    = [string][int](Down 0x51)
        'R grip'    = [string][int](Down 0x46)
    }
    $changed = $false
    foreach ($k in $state.Keys) {
        if ($last[$k] -ne $state[$k]) {
            $record.Add("$($clock.ElapsedMilliseconds)`t$k $($state[$k])")
            $last[$k] = $state[$k]
            $changed = $true
        }
    }
    if ($changed) {
        $lines = $state.GetEnumerator() | ForEach-Object { "$($_.Key) $($_.Value)" }
        [IO.File]::WriteAllLines($inputFile, [string[]]$lines)
    }
    Start-Sleep -Milliseconds 30
}
$neutral = 'L stick 0 0', 'R stick 0 0', 'R trigger 0', 'L trigger 0', 'R a 0', 'R b 0', 'L x 0', 'L grip 0', 'R grip 0'
[IO.File]::WriteAllLines($inputFile, [string[]]$neutral)
$record.Add(('{0}' -f $clock.ElapsedMilliseconds) + "`tEND")
[IO.File]::WriteAllLines($recordFile, $record)
Write-Host "Grabacion guardada: $recordFile ($($record.Count) eventos, $([int]($clock.ElapsedMilliseconds/1000)) s)"
