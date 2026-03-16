# Hypercolor — Development Roadmap

This file is the canonical roadmap. Update it as work is completed or priorities shift.

---

## Phase 0 — Foundation Cleanup (audit findings)

These must be resolved before building new features on top of fragile ground.

- [ ] **Delete `fog_overlay.gd`** — orphaned dead code. Not attached to any scene node, not referenced in `main.gd`. Actual darkness is handled by `CanvasModulate` + player `PointLight2D` nodes.
- [ ] **Fix stats-before-super() ordering trap** — `player.gd` and `enemy.gd` must set stats before `super._ready()` due to an implicit ordering contract. Introduce a virtual `_init_stats()` method on `Entity` that `_ready()` calls before initializing `current_life`/`current_mana`. Subclasses override `_init_stats()` instead of setting vars freehand.
- [ ] **Resolve dual source of truth for light values** — `main.gd` defines light constants and overwrites scene node values at runtime, making the editor inspector show stale values. Either drive lights fully from exported vars (so the editor reflects reality) or strip the scene values and own them entirely in code. Pick one.
- [ ] **Clear stale `tile_map_data` blob from `main.tscn`** — large `PackedByteArray` that gets wiped by `tile_map_layer.clear()` on every run. Open the scene in the editor, clear the tilemap, and save so the blob doesn't live in version control.
- [ ] **Add Enemy state machine tests** — `_update_state()` and `_process_state()` in `enemy.gd` are pure deterministic logic and should be covered. Test IDLE→CHASE on aggro range entry, CHASE→ATTACK on attack range entry, ATTACK→CHASE on range exit, and IDLE leash on distance.

---

## Phase 1 — Loot System (core ARPG loop)

The most impactful missing feature — this is the D2 dopamine loop.

- [ ] **Item data model** — `Item` resource class with: `item_name`, `item_type` (weapon/armor/gold), `damage_min`/`damage_max`, `attack_rating_bonus`, `defense_bonus`. Keep it flat; no inheritance tree yet.
- [ ] **Drop on death** — enemies call a `LootTable.roll()` static on `_die()`. Start simple: fixed drop rates (e.g. 60% chance gold 1–15, 20% chance weapon, 10% chance armor).
- [ ] **Ground item scene** — small glowing pickup node that sits on the floor. Click to pick up. Different tint per item type (gold = yellow, weapon = white, armor = blue).
- [ ] **Inventory (flat list)** — player holds an array of `Item`. No grid UI yet — just a collection.
- [ ] **Equipment slots** — player has `equipped_weapon` and `equipped_armor` vars. Clicking a ground item auto-equips if slot is empty, otherwise adds to inventory. Equipped items modify `base_damage_min/max`, `base_attack_rating`, `base_defense` on the player.
- [ ] **HUD inventory hint** — small text indicator showing equipped weapon name and armor name. No full inventory screen yet.

---

## Phase 2 — XP and Leveling

- [ ] **XP on kill** — each enemy has an `xp_reward` value. Player accumulates `current_xp`.
- [ ] **Level thresholds** — simple exponential curve (e.g. `level^2 * 100` XP to next level).
- [ ] **Level-up stat points** — on level up, player gets 5 stat points to distribute. For now, auto-allocate by class archetype (warrior: STR/VIT). Manual allocation UI is a later phase.
- [ ] **HUD XP bar** — thin bar across the bottom of the screen between the two orbs, D2-style.

---

## Phase 3 — Player Death and Game State

- [ ] **Death state** — player `_die()` currently does nothing (base `Entity._die()` just sets `is_alive = false`). Add a game-over overlay and a restart button that reloads the scene.
- [ ] **Respawn / restart flow** — regenerate a fresh dungeon on restart. Eventually: return to a main menu scene.

---

## Phase 4 — Multiple Enemy Types

- [ ] **Enemy variant: Brute** — higher STR/VIT, slower speed, higher XP reward. Reuse the existing `Enemy` scene with different exported stat values.
- [ ] **Enemy variant: Skirmisher** — low HP, fast, high DEX (harder to hit). Drops more frequently.
- [ ] **Spawn table per level** — dungeon generator assigns enemy types to spawn points based on room depth/index.

---

## Phase 5 — Level Progression

- [ ] **Stairs tile** — special floor tile placed in the last room. Stepping on it triggers a new dungeon generation (same scene, re-run `_ready()` logic or reload scene).
- [ ] **Depth counter** — track current dungeon depth. Increase enemy stats and loot quality with depth.

---

## Phase 6 — Minimap

- [ ] **Explored room tracking** — dungeon generator tags which rooms the player has entered.
- [ ] **Corner overlay** — small top-right minimap drawn as simple colored rectangles (rooms = dark, corridors = darker, current room = bright). No fog on minimap for now.

---

## Deferred / Future

- BSP dungeon generation (richer room shapes)
- Manual stat point allocation UI on level-up
- Full inventory grid screen (D2-style)
- Skill system (D2-style active skills, mana cost)
- Sound effects and music
- Real sprite art (replace placeholders)
- Multiple character classes at new game
