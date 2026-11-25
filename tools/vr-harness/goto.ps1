param(
    [double[]]$Waypoints = @(),     # x1,y1,x2,y2,... in Barony tiles
    [double]$Face = -1,              # optional final heading in degrees (0 = +x, 90 = +y)
    [double]$Tolerance = 0.25,
    [int]$TimeoutSec = 40
)
# Closed-loop navigation for BaronyVR test runs (needs BARONYVR_TEST_INPUT).
$poseFile = 'D:\Juegos\SteamLibrary\steamapps\common\Barony\vr_debug\pose.txt'
$inputFile = 'D:\Workspace\BaronyVR-deps\vrinput.txt'
function Send([string]$ls, [string]$rs) {
    [IO.File]::WriteAllLines($inputFile, [string[]]@("L stick $ls", "R stick $rs", 'R trigger 0', 'R a 0'))
}
function Pose {
    for ($i = 0; $i -lt 20; $i++) {
        try { $t = (Get-Content $poseFile -ErrorAction Stop -TotalCount 1).Split(' ')
              return @{ x = [double]$t[0]; y = [double]$t[1]; h = [double]$t[2]; prompt = $t[3] -eq '1'; text = ($t[7..($t.Count-1)] -join ' ') } } catch { Start-Sleep -Milliseconds 30 }
    }
    throw 'pose.txt not available'
}
function Wrap([double]$a) { while ($a -gt 180) { $a -= 360 }; while ($a -lt -180) { $a += 360 }; $a }
$deadline = (Get-Date).AddSeconds($TimeoutSec)
for ($w = 0; $w -lt $Waypoints.Count; $w += 2) {
    $tx = $Waypoints[$w]; $ty = $Waypoints[$w + 1]; $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        $p = Pose
        $dx = $tx - $p.x; $dy = $ty - $p.y; $dist = [Math]::Sqrt($dx * $dx + $dy * $dy)
        if ($dist -lt $Tolerance) { break }
        $diff = Wrap(([Math]::Atan2($dy, $dx) * 180 / [Math]::PI) - $p.h)
        if ([Math]::Abs($diff) -gt 14) { Send '0 0' ("{0} 0" -f ([Math]::Sign($diff) * [Math]::Min(0.9, 0.35 + [Math]::Abs($diff) / 120))) }
        else { Send ("0 {0}" -f [Math]::Min(0.85, 0.35 + $dist)) '0 0' }
        Start-Sleep -Milliseconds 60
    }
    Send '0 0' '0 0'
    $p = Pose; "waypoint $($w/2): at ({0:N2},{1:N2}) heading {2:N0}" -f $p.x, $p.y, $p.h
}
if ($Face -ge 0) {
    while ((Get-Date) -lt $deadline) {
        $p = Pose; $diff = Wrap($Face - $p.h)
        if ([Math]::Abs($diff) -lt 6) { break }
        Send '0 0' ("{0} 0" -f ([Math]::Sign($diff) * [Math]::Min(0.8, 0.3 + [Math]::Abs($diff) / 150)))
        Start-Sleep -Milliseconds 60
    }
    Send '0 0' '0 0'
}
Start-Sleep -Milliseconds 400
$p = Pose; "final ({0:N2},{1:N2}) heading {2:N0} prompt={3} {4}" -f $p.x, $p.y, $p.h, $p.prompt, $p.text
