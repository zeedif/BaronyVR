# Direct flow: fresh game -> spawn (5.5,8.5) -> lever at wall tile (14,17).
# Stand on (15.5,17.5) facing west (180 deg); the gate is at (15.5..16.5,18.5).
param([switch]$NoStart)
if (-not $NoStart) { & D:\Workspace\BaronyVR-deps\start-run.ps1 }
& D:\Workspace\BaronyVR-deps\goto.ps1 -Waypoints 13.0,12.0,15.2,16.4,15.5,17.5 -Face 180 -TimeoutSec 45
