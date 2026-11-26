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
| ZF7 | Wrist UI could not be checked without controllers. | `BARONYVR_TEST_FAKE_HANDS=1` gives untracked hands synthetic poses (`BARONYVR_TEST_LEFT_HAND` / `_RIGHT_HAND` = "x,y,z,yaw,pitch,roll"); gameplay only. |
| ZF8 | Hotbar on a waist belt, far below the view. | `hotbar=view` (default): hotbar and dungeon messages stay at the bottom of the head-locked GUI layer; `hotbar=belt` restores v1.0.2. |
| ZF9 | Every screen opened wherever the head pointed. | Vivecraft `guiAppearOverBlock`: chest, shop, workstation, alembic and mailbox screens open toward that object, slightly below eye level; switching screens re-places the panel; gameplay screens stay static (only title/pause/calibration menus follow lazily). |
| ZF10 | Wrist HUD always on and small. | `wrist_ui=look` (default): health/mana/status effects (left forearm) and minimap (right wrist) appear while the wrist is looked at (28°/38° hysteresis); 1.5x larger. `wrist_ui=always` keeps them visible. |
| ZF11 | Hotbar followed head pitch; prompts were head-locked; no way to pause without the SteamVR system menu. | Extra OpenXR quad layers with their own swapchains: body-locked hotbar + messages (below eye height, lazy yaw follow at 35°), interaction prompt anchored at Barony's active world-tooltip entity (in range, not necessarily centred), Demeo-style left-hand menu (Pause, Inventory, Spells, Map, Log) drawn with Barony button art and localized strings, right-ray hover + trigger/A. Wrist panels need a real watch gesture (forearm across the view, controller face toward the eyes). |
| ZF12 | Menu cursor drawn beside the click point; trigger squeeze shifted the ray to the next cell; an untracked controller locked the desktop mouse out. | Cursor centred on its hotspot like Barony, cursor frozen during trigger travel and until a drag leaves a dead zone, laser requires a tracked aim pose. |
| ZF13 | Xbox-style mapping in VR: no prev/next hotbar, trigger not interacting. | Right trigger = attack, or Use while a prompt shows; A use; B spell; grip taps = hotbar prev/next (linear hotbar forced in VR); right stick up / Y equip; X inventory; holds keep grab/drink/backpack/bow. |
| ZF14 | Test automation. | `BARONYVR_TEST_INPUT` drives simulated controllers from a file; `vr_debug/pose.txt` logs pose, active prompt and nearby levers/gates/doors; scripts in `tools/vr-harness` (closed-loop navigation, keyboard teleop + replay, direct flow to the first-room lever). |
| ZF15 | Hand buttons huge and always on; minimap on the outer side of the arm; Menu button left Barony half-paused; grip-cycling the hotbar too slow; prompts blinked and depended on body heading. | Barony's interaction cone now follows the head (`vrInteractYaw` / `vrInteractAngle` hooks in `player.cpp`); prompts drawn by the mod at the active tooltip with a 300 ms bridge and a "next interaction" hint. Wrist panels are small OpenXR quads beside the wrist on the side toward the eyes (left: HP/MP, effects, Menu/Inventory/Spells/Map; right: minimap), shown only with a close watch gesture (150 ms in / 250 ms out). Pause uses the native Start path. Hotbar: point with either hand, its trigger equips; Y = pause, L3 = call out, R3 = next interaction. |
| ZF16 | Separate minimap panel was opaque and large; no pointer feedback; prompts out of view; B closed every window. | One wrist panel (effects, HP/MP, minimap, shortcuts) on the hand that makes the watch gesture first, the other hand points at it with Barony's hand cursor drawn where its ray lands; relaxed facing thresholds. Prompts kept in an eye-level band at the object. X/Y own in-game windows (inventory X closes, Y spells; other windows X/Y close; pause Y resumes), B only means back in title menus; trigger joins the lobby like A. |
| ZF17 | X/Y window shortcuts reopened the inventory on the closing press (shootmode returned while X was still held) and left no way to close. | X and Y unassigned in game (the wrist panel covers inventory, spells, map and pause); B is back/close in every menu again. |
| ZF18 | Wrist Menu paused the game with an invisible menu; sticks stopped moving/turning in game; hotbar pointing lost the slot and had no cursor; dark box behind wrist HP/MP and map. | Pause opened the way Barony's own UI does (pauseGame + pause_menu_owner = clientnum + createMainMenu), since pauseGame picked a stale menu owner from a synthetic press. VR pad re-bound in game when missing (KeyboardLogin drops it). Hotbar: nearest slot in the row band, 250 ms sticky selection, hand cursor on the panel. Wrist backdrop removed. |
| ZF19 | VR actions were faked as keyboard/gamepad presses (Space login dropped the controller). | `Input::update()` ORs device-independent VR actions into named bindings (`g_vrActionHook`); Use, Cast Spell, Hotbar Up / Select, Interact Tooltip Next, Call Out, Show NPC Commands and GamepadLoginA are injected by name. Stick clicks cycle interactions when one is in reach, otherwise L3 Call Out / R3 NPC commands; prompt shows L3/R3 glyphs. |
| ZF20 | B could not close the assist shrine (or other windows) once the VR pad was the player's controller: Barony maps Escape to "close windows" only for keyboard players and pauses otherwise. No feedback for charging, striking or blocking (tracked arms skip Barony's animations). Wrist panel sometimes cut off. | In game B injects the native `Pause Game` action (closeAllGUIs with a window open); Escape is kept for title/pause/game-over menus; the B press that closes a window cannot also cast. Haptics: charge start/full, recognised melee swing, trigger attack/use, shield raised, timed block; block/charge cue drawn 2.5x. Wrist panel kept at least 0.30 m from the eyes (a close wrist put it inside the near plane). |
| ZF21 | Attacking with the trigger only charged (the hit was an arm swing, host-only: a client's attack needs a validated packet, and nobody else sees the gesture); weak repeated attacks on a trigger are tiring. In the lobby, once the card was signed in, the laser stopped reaching it and B sent Escape. | `combat=button` (default): A = injected `Attack` (native hold-to-charge, release-to-strike, works for clients), X = `Defend` + `Sneak`, both triggers = `Use`; charge cue + haptics read the HUD weapon's native charge. `combat=gesture` keeps the physical swing / two-hand bow. Signed-in lobby card: trigger = injected `MenuConfirm` (after the sign-in press is released), B = `MenuCancel`, no Escape, no laser click. |
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
-DCMAKE_POLICY_VERSION_MINIMUM=3.5`. `packaging/dev/Make-DevZip.ps1 -Build <dir>` creates a shareable zip; players run
`Instalar.cmd` (double click) to copy it into `%LOCALAPPDATA%BaronyVRManaged`.

## Next (planned)

- Check ZF9 placement and ZF10 thresholds on a real headset.
- Multiplayer: broadcast head/hand poses (new `VRPS` packet, only to peers that
  announced BaronyVR; vanilla peers ignore unknown packets) so remote players see
  VR arm gestures.
- More controller profiles (Index, Vive, WMR) for SteamVR users.
