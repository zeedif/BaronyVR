# Headset-free test harness (Windows, SteamVR null driver)

Paths inside the scripts point to `D:\Workspace\BaronyVR-deps` (build + deps) and
the Steam Barony folder; adjust them for another machine.

1. Enable SteamVR's null HMD (see `docs/ZF_DEV_NOTES.md`), back up `steamvr.vrsettings`.
2. `start-run.ps1` launches the dev build with the test hooks, walks the menus
   (keyboard/mouse) into a new local game and prints the spawn pose.
3. `flow-lever.ps1 -NoStart` walks from the fixed first-room spawn (5.5,8.5) to
   the lever at wall tile (14,17): stands on (15.5,17.5) facing 180 degrees.
4. `vrinput.ps1 -Set "R trigger 1" -HoldMs 300 -After "R trigger 0"` drives the
   simulated controllers; `goto.ps1 -Waypoints x,y,... -Face deg` navigates
   closed-loop using `vr_debug/pose.txt`.
5. `teleop.ps1` maps the keyboard to the simulated controllers and records a
   session (`replay.ps1` plays it back). `desk.ps1` screenshots the desktop view.

Game-side hooks (env vars): `BARONYVR_DEBUG_DUMP`, `BARONYVR_TEST_FAKE_HANDS`,
`BARONYVR_TEST_INPUT`, `BARONYVR_TEST_LEFT_HAND`, `BARONYVR_TEST_RIGHT_HAND`,
`BARONYVR_TEST_LOBBY_A`. The null HMD reports a 180-degree head roll, so
head-space values in `state.txt` show x and y mirrored.
