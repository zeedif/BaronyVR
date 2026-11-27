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
| ZF22 | Buttons for attack/defend were uncomfortable; attacks went where Barony's body yaw faced (head turns never turn the body); the hotbar followed every head turn and could be pointed at (and scrolled) with an arm hanging down; wrist panel sometimes showed only its buttons. | Ambidextrous button combat: right trigger = Attack, left trigger = Defend/Sneak, A or X = Use, B or Y = Cast Spell / back. Attack direction = right controller yaw: local melee trace and projectiles (`vrLocalAttackAimYaw`); a VR client appends "VR"+yaw16 to its ATAK packet and a BaronyVR host applies it to that client's melee trace and arrows/thrown items (vanilla peers ignore the extra bytes). Hotbar: re-centres only after >55° for 1 s and never while in view, position follows slowly, rays only while it is in view. Wrist panel draws HP/MP bars from stats and a text "MENU" label instead of copying Barony's HUD frames. Lessons from Team Beef, Quake VR, OpenMW-VR and Vivecraft in the research notes below. |
| ZF23 | Dungeon messages (NPC lines) sat bottom-left and were unreadable; hotbar still in the way of attacks and slow to re-centre; wrist panel still showed cut off (its texture was complete, so the compositor quad was the problem) and ZF20's minimum distance pulled it off the arm; the signed-in lobby card ignored the laser. | Messages on their own panel centred below the view; hotbar lower (0.58 m) and yaw-locked to the head with no delay. Wrist panel rendered into its own texture and drawn inside each eye image (`glDrawVrUiTexture`, on top of hands/shield), `wrist_render=layer` restores the quad; back on the wrist. Lobby: the card widget under the ray gets the controller focus (trigger/A confirm it). `debug_dump=<s>` in vr_settings.cfg. Harness note: the null HMD eye dumps are mirrored left/right. |
| ZF24 | Wrist panel upside down in the headset; subtitles were a screen crop (it caught hotbar slots, and the hotbar crop caught the text); after a game, the trigger stopped joining the lobby (A still worked). | Wrist image up axis flipped (GL rows are bottom-up). Messages drawn by the mod from Barony's live message fields (text, font, colours), and erased from the hotbar copy. Lobby join detection no longer requires `inputstr == nullptr` (the in-game command/chat buffer can stay set); in the lobby A confirms with the same injected `MenuConfirm` as the trigger instead of the virtual pad. Every VR input context change is logged (`[VR ZF24] context=...`). Harness note: null-HMD eye dumps are rotated 180 degrees relative to the headset. |
| ZF25 | Subtitles lost Barony's colours (the wizard's purple showed white); on the join screen the trigger often did nothing until A/B was pressed, and in game the left stick sometimes did not walk. | Subtitles tinted with each field's colour times the frame opacity, like `Field::draw`. Root cause of the other two: upstream GA21 "thumbrest D-pad" mode. On Quest controllers resting the right thumb on the thumbrest turned the left stick into a D-pad (movement axes zeroed) and made menu navigation invalid (no trigger clicks, no lobby join); pressing A/B lifted the thumb. Now opt-in (`thumbrest_dpad=1`). Menu presses in title/lobby log `[VR ZF25] menu primary ...` with every gating condition. Test hook: a posed fake hand (`R pose ...` in the input file) also works in menus, so the laser can be tested. |
| ZF26 | Hotbar too low (looking at it triggered the Quest floor view); after using a lever and walking back, the next interaction prompt showed the hotbar until the next interaction. | Hotbar at 0.50 m below the eyes, subtitles above it. The ZF3 rule that kept a large rectangle around Barony's tooltip on the head-locked GUI layer whenever the mod's prompt panel was off is gone (it exposed the hotbar under it); the prompt panel falls back to the tooltip's own "prompt text" when `interactText` is empty, so it no longer switches off. Panel visibility is logged (`[VR ZF26] panels ...`). |
| ZF27 | A small copy of the hotbar flickered inside the interaction prompt at the edge of its range (earlier: a bigger hotbar next to new subtitles, a cut-off wrist panel). Every panel texture was correct in the dumps. | The quad layer list changed whenever a panel appeared/disappeared, and the SteamVR compositor briefly showed one layer's image with another layer's pose. All gameplay panels are now created when gameplay starts and submitted every frame in a fixed order; a hidden panel shows a transparent image instead of leaving the list (verified: 5 layers on every frame across the prompt range edge). |
| ZF28 | Enemy health bars (and world icons / NPC speech bubbles) faced the body heading, not the head. | `glDrawEnemyBarSprite`, `glDrawWorldUISprite` and `glDrawWorldDialogueSprite` billboard toward `camera->ang - vrHeadYaw` / `camera->vang - vrHeadPitch`, like the VR view matrix (desktop unchanged). |
| ZF29 | Multiplayer test: the host could not move until the desktop window was focused again; in the solo lobby card B did nothing and A pressed something else; after "ready" the trigger activated the lobby-code buttons Barony had focused. | Host log showed `context=gameplay focused=0` right after pausing: the left menu button (also mapped to Start) opens the SteamVR dashboard on Quest, which takes the OpenXR input focus. It no longer pauses; session state changes are logged and a lost focus in game shows a hint. Lobby: pointing at the name field + trigger started text entry, and Barony ignores all widget input while `inputstr` is set; fields are no longer pointer targets, B ends a text edit with Return. The pointer can focus any lobby widget (top-left ATRAS, code buttons) except other players' cards, and the trigger confirms only when it points at a widget. Client-without-UI report still needs the client's log. |
| ZF30 | The name field should stay pointable. | Fields are pointer targets again; a field in text-edit mode is closed (`Field::deactivate`, text kept) as soon as the ray moves onto another lobby widget, or with B (that B press does not also go back). |
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

## Research notes: input in open-source VR ports (2026-11)

- Team Beef (QuestZDoom, Lambda1VR, RTCWQuest, JKXR): dominant trigger fires,
  A uses; buttons become engine keys (rebindable); `vr_control_scheme` /
  `vr_switch_sticks` for left-handers; weapon aim from the controller quaternion
  rotated by `viewYaw - hmdYaw`; Lambda1VR melee is physical in single player
  and a trigger press in multiplayer.
- Quake VR (vittorioromeo): controller buttons are bindable Quake keys; clients
  send head/hand poses in move packets, the server judges melee, the client owns
  aim; remote players are yawed by their main-hand aim. Older Quakespasm VR has
  aim modes with a yaw deadzone before the body turns.
- OpenMW-VR: speed-gated "realistic combat" state machine; bows/spells aimed
  along the hand; the UI pointer disables combat while active; OpenXR actions
  rebindable in game.
- Vivecraft: every keybind is a SteamVR action, switched by context action sets
  (in game / GUI / keyboard); HUD on wrist, hand or head; server plugin syncs
  poses and fixes VR projectiles.
- Next for BaronyVR: a real "VR" device type in Barony's Input bindings
  (rebindable in the controls menu, handedness option), and a pose packet so
  remote players face their weapon hand.
