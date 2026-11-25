# zeedif/BaronyVR – development notes (branch `vr-ux-improvements`)

Based on upstream `release/v1.0.2`. Changes are tagged `ZFn` in `src/vr_openxr.cpp`.

## Fixes in this branch

| Tag | Problem | Fix |
| --- | --- | --- |
| ZF1 | Started from SteamVR (Steam Link, Virtual Desktop, Index...) the game stayed on the desktop. The OpenXR loader always used the system *active* runtime (Meta Horizon), which has no headset when Link is not connected. | Runtime selection: `xr_runtime=auto` (default) uses SteamVR when `vrserver.exe` is running, else the active runtime, and falls back to the other one if no headset is found. Also `active`, `steamvr`, or a runtime `.json` path, in `vr_settings.cfg` or `BARONYVR_XR_RUNTIME`. An explicit `XR_RUNTIME_JSON` always wins. |
| ZF5 | With SteamVR the session stayed in `SYNCHRONIZED` forever: frames were only submitted when `shouldRender` was true, and SteamVR waits for submitted layers before going `VISIBLE`/`FOCUSED`. | Keep rendering/submitting while `SYNCHRONIZED`. |
| ZF6 | Title/main menu invisible: v1.0.2 anchors the menu panel in the world where the headset faced on the first tracked frame (often the desk/monitor) and never moves it. | Lazy follow: if the panel is >50° off the view direction (or the player walked >1 m) for 0.65 s, it is placed in front again. Not while a trigger is held. |
| ZF2 | Lobby "press SPACE / A to join" ignored all controller buttons: the VR gamepad binding raced with Barony releasing controllers when it rebuilds the card, and for online clients the wrong input slot was refreshed. | A on the join card sends Barony's `KeyboardLogin` (Space); the gamepad A is suppressed for that press. Also refreshes `Input::inputs[clientnum]`. |
| ZF3 | In the dungeon the centre interaction prompts (inspect door, pick up torch, pull lever...) never appeared: during gameplay the whole flat GUI copy is cleared, and the separate "forward" surface only existed for prompts with text. | The world-tooltip rectangle is kept on the view-centred GUI layer (where interaction is aimed); the duplicate forward surface is disabled. |
| ZF4 | No way to see what the headset shows without wearing it. | `BARONYVR_DEBUG_DUMP=<seconds>` writes `vr_debug/eye_NNN.bmp` (left eye), `vr_debug/gui_NNN.bmp` (GUI panel, magenta = transparent) and `vr_debug/state.txt` (session/menu/panel pose) next to `log.txt`. |

## Headset-free test setup (used for this branch)

1. SteamVR null driver: in `Steam\config\steamvr.vrsettings` set
   `steamvr.forcedDriver="null"`, `steamvr.activateMultipleDrivers=true`,
   `driver_null.enable=true` and disable standby
   (`power.pauseCompositorOnStandby=false`, `power.turnOffScreensTimeout=86400`) –
   otherwise the null HMD enters standby and sessions never get focus. Back up the
   file first and restore it afterwards.
2. Run `barony.exe` from the retail folder with `PATH=<build dir>;<retail dir>`,
   `SteamAppId=371970`, `BARONYVR_DEBUG_DUMP=1`.
3. Drive menus with keyboard/mouse (window coordinates); `BARONYVR_TEST_LOBBY_A=1`
   simulates the A button on the lobby join card (the null HMD has no controllers).

Limits: no controllers and a static head pose, so hand-driven UI, head movement
(ZF6) and gameplay prompts (ZF3) still need a real headset check.

## Build (Windows)

vcpkg (x64-windows): `sdl2 sdl2-image sdl2-net sdl2-ttf physfs glew freetype libpng
zlib openxr-loader rapidjson jsoncpp dirent`; Steamworks SDK 1.59 headers
(interfaces match retail build 22630456); FMOD 2.02.x headers with an import lib
generated from retail `fmod.dll`; nativefiledialog built from source. Configure with
`STEAMWORKS_ENABLED=1`, `EOS_ENABLED=0`, `-DFMOD_ENABLED=ON
-DCMAKE_POLICY_VERSION_MINIMUM=3.5`. `packaging/dev/Install-DevBuild.ps1` installs a
build into the managed BaronyVR install (with backup), `Restore-DevBuild.ps1` undoes it.

## Next (planned)

- Wrist UI (Vivecraft `HUDLock.WRIST`, Demeo): hotbar on the left forearm, shown
  when the wrist is turned toward the face; small wrist buttons for Inventory,
  Menu (Esc), Spells and Map instead of the head-following belt.
- Modal screens (inventory, chest, shop, Esc) open in front of the player at open
  time; chests optionally above the chest (Vivecraft `guiAppearOverBlock`).
- Multiplayer: broadcast head/hand poses (new `VRPS` packet, only to peers that
  announced BaronyVR; vanilla peers ignore unknown packets) so remote players see
  VR arm gestures.
- More controller profiles (Index, Vive, WMR) for SteamVR users.
