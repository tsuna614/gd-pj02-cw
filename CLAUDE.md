# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Crimson Warrior" — a 2D side-scrolling action platformer in Godot 4.6 (GDScript, Forward Plus renderer, 1920×1080 viewport). There is no build step, linter, or test suite. Open the project in the Godot editor (`/Applications/Godot.app`, configured in `.vscode/settings.json`) and run with F5; the main scene is set by UID in `project.godot`. `godot` is not on `PATH`; the CLI is `/Applications/Godot.app/Contents/MacOS/Godot`.

Closest thing to a lint/compile check (resolves project `class_name`s, so it catches type errors and bad member references):

```sh
GODOT=/Applications/Godot.app/Contents/MacOS/Godot
$GODOT --headless --path . --import                                   # refresh .godot/ cache (needed after adding a class_name)
$GODOT --headless --path . --check-only --script scenes/characters/player/attack_state.gd
```

`--check-only` exits 0 even on failure — look for `SCRIPT ERROR` in the output.

`.godot/` is gitignored editor cache. Every `.gd` has a committed `.gd.uid` sidecar — keep them with the script (including when moving/renaming, so scene references don't break). Scene/resource files (`.tscn`, `.tres`) are Godot-generated text; prefer editing them in the editor, and keep any hand edits minimal.

## Layout

- `scripts/` — reusable, scene-agnostic code (`state_machine/`, `globals/`).
- `scenes/characters/` — a character's `.tscn` and its scripts live together (`player/`, `NPCs/enemies/`).
- `scenes/scenes/` — level scenes (`test_scene.tscn`, plus a `Camera2D` script that clamps limits to the `TileMapLayer` used rect).
- `assets/game/` — Knight sprites and tile art; `tilesets/game_tile_set.tres` is the TileSet.

## Architecture: node-based state machine

Character behaviour is a state machine built from **child nodes**, not code:

- `NodeStateMachine` (`scripts/state_machine/node_state_machine.gd`) is a `Node` child of the character (`Player/StateMachine`). On `_ready` it registers every `NodeState` child in a dictionary keyed by **lowercased node name**, wires each state's `transition` signal to `transition_to`, and sets `state.actor = get_parent()`. The `initial_node_state` export is entered via `call_deferred` so the parent's `_ready` finishes first.
- Each frame, `_physics_process` calls the current state's `_on_physics_process(delta)` and then `_on_next_transitions()`. States never call each other; they `transition.emit("name")`.
- **State names are node names.** `transition.emit("run")` resolves to the child node named `Run` in `player.tscn`. A transition to a name with no matching node is silently ignored (no error), and a transition to the current state is a no-op. `transition_to` reads `current_node_state.name` before any null check, so emitting a transition before the deferred initial state has been entered crashes.
- To add a state: subclass `NodeState` (override `_on_enter/_on_exit/_on_process/_on_physics_process/_on_next_transitions`), add a child `Node` with that script under `StateMachine` in the scene, and name it to match the string used in `transition.emit(...)`. Cast `actor` to the concrete type (`var player := actor as Player`).
- The state machine prints the current state every physics frame (`node_state_machine.gd`); expect that noise in the console.

### Player (`scenes/characters/player/`)

`Player` (`player.gd`) owns shared data and helpers; states (`idle/run/jump/attack_state.gd`) own behaviour and movement (`apply_gravity`, `move_and_slide`).

- `Player._physics_process` runs **once per frame before the states** to poll input into `move_direction` / `has_move_input` and tick timers. States should read these cached values rather than polling `Input` for movement.
- Timers are `CountdownTimer` (`scripts/globals/countdown_timer.gd`, a `RefCounted` you `start()` and `tick(delta)` manually — not a scene `Timer` node). `Player` ticks coyote, jump-buffer, and combo timers. Note the timers are constructed with the export defaults at field-init time, so changing `coyote_time`/`jump_buffer_time`/`combo_reset_time` in the inspector does not change the timer's `duration`.
- `GameInputEvents` (`scripts/globals/game_input_events.gd`) is a static helper class (not an autoload). `movement_input()` keeps a static buffer of held left/right so the most recently pressed direction wins; it mutates state on each call, so it should only be called from `Player._update_input`. Call `GameInputEvents.reset()` on respawn/scene reload.
- Input actions (`project.godot`): `move_left`, `move_right`, `jump`, `dash`, `attack`.
- Attack combo: `combo_index` (0 = not attacking, 1–3 = active swing, matching `attack_1..3` animations) and `combo_buffered` live on `Player`; `AttackState` advances the chain when a swing's animation finishes, then idles inside a `combo_reset_time` window (`_awaiting_chain`) to catch a late press before returning to `idle`. Animation `is_playing()` is used to detect swing end, so the attack animations must not loop.

### Work-in-progress gaps

The codebase is mid-build. States are referenced in transitions (`dash`, `wallslide`) that have **no scripts or nodes yet**, so those transitions currently do nothing — e.g. `JumpState`/`FallState` emit `wallslide` but the player has no `Wallslide` state. `Player.check_common_transitions()` is defined but unused. `walk_state.gd` is an empty template and not in the scene. `chicken.gd` is the stock Godot `CharacterBody2D` template (uses `ui_*` actions), not real enemy AI. Verify a state actually exists in `player.tscn` before relying on a transition to it.
