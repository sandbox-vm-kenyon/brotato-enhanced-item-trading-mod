# Architecture & Design Notes

## Bug Root Cause: Weapon Trading Breaks for Tier 2+ Weapons

### What Breaks
After a Brotato game update, trading any weapon above tier 1 plays the "fail" sound and does nothing.

### Code Path
`coop_item_popup.gd` → emits `weapon_trade_button_pressed_coop` →  
`coop_shop.gd::on_weapon_trade_button_pressed_coop` → calls `_can_weapon_be_bought(weapon_data, to_player_index)`

### Root Cause in `_can_weapon_be_bought`
The function is a copy of the vanilla shop's buy-eligibility check. The key line:

```gdscript
var weapon_slot_available: bool = RunData.has_weapon_slot_available(weapon_data, player_index)
```

In vanilla, `has_weapon_slot_available` doesn't just count free slots — it checks whether the weapon can be *acquired from the shop*, which includes checking the upgrade path. For tier 1 weapons, this works because the shop sells tier 1 and can upgrade to tier 2. For tier 2+ weapons, the function returns `false` because the shop never sells tier 2+ directly — you only get them by upgrading.

The final `return weapon_slot_available` therefore always returns `false` for tier 2+ weapons, even when the receiving player has a completely free weapon slot.

### Fix
Replace the vanilla shop eligibility check with a direct "does this player have a free weapon slot" check for trading purposes:

```gdscript
func _can_weapon_be_traded(weapon_data: WeaponData, player_index: int) -> bool:
    var weapons = RunData.get_player_weapons(player_index)
    var max_weapons = RunData.get_player_max_nb_weapons(player_index)
    # A free slot exists: can receive the weapon as-is
    if weapons.size() < max_weapons:
        return true
    # No free slot: check if player has the tier-below version (can upgrade in-place)
    if weapon_data.tier > 1:
        for existing in weapons:
            if existing.weapon_id == weapon_data.weapon_id and existing.tier == weapon_data.tier - 1:
                return true
    return false
```

**Verified against decompiled Brotato 0.6.1.6 source** (decompiled 2026-06-20 using GDRETools v2.5.0):

- `get_free_weapon_slots(player_index)` — exists in vanilla at `singletons/run_data.gd:1335`
- `get_player_effect(key: int, player_index)` — takes **int hash key**, not string
- `Keys.no_melee_weapons_hash`, `Keys.no_ranged_weapons_hash`, `Keys.no_duplicate_weapons_hash`, `Keys.lock_current_weapons_hash` — correct hash names
- `add_weapon(weapon_data, player_index)` — direct RunData method for adding weapons (correct for trades)

**Actual Fix — bypass `buy_weapon` entirely for trades:**
`buy_weapon` in `base_shop.gd` calls `has_weapon_slot_available` internally AND does a `_elements.add_element` (shop visual container) before the slot check. For trades, we call `RunData.add_weapon` directly and refresh the gear container UI manually. This works for all weapon tiers.

We still keep the melee/ranged/duplicate restriction checks, updated to use correct hash keys.

---

## Locker Feature Design

### Goal
Let a player "park" one weapon temporarily so they can trade/buy without needing to sell or combine. The weapon comes back when there's a free slot.

### Implementation Approach

#### The Locker as an Item
- Create a new `ItemData` resource: `item_locker`
- Give it to every player at run start (via `run_data.gd` extension, in `_ready` after coop setup)
- The item has no passive effects — it's purely a UI container
- It is marked non-tradeable and non-discardable

#### Locker State
- Stored in `run_data.gd` extension as `var locker_weapons: Array` (one entry per player, null or WeaponData)
- Persists through waves (locker contents survive to the next shop)

#### UI: "Set Aside in Locker" Button
- In `coop_item_popup.gd`, when the selected element is a `WeaponData` and the player's locker is empty, show an additional button "Set Aside in Locker"
- On press: call `RunData.set_locker_weapon(player_index, weapon_data)`, then call `process_player_weapons_inventory(weapon_data, player_index)` to remove it from the player's active weapons

#### UI: Retrieve from Locker
- In `coop_item_popup.gd`, when the selected element is `item_locker` and `RunData.get_locker_weapon(player_index) != null`:
  - Show button "Get \<WeaponName\> from Locker" (only if player has a free weapon slot)
  - On press: call `.buy_weapon(locker_weapon, player_index)` then clear the locker

#### Starting Items
- Vanilla `add_starting_items_and_weapons()` is overridden in `run_data.gd` extension
- After calling parent `.()`, we call `add_item(locker_item_data, player_index)` for each player
- Respects `is_locker_enabled` and `is_locker_in_solo` config flags
- `locker_item_data` is loaded and set by `mod_main._ready()` via `ItemService.add_mod_item()`

#### Item Resource
- `items/locker/item_locker_eit_data.tres` — Godot resource file extending `item_data.gd`
- `my_id = "item_locker_eit"`, `can_be_looted = false`, `is_lockable = false`, `max_nb = 1`
- Loaded at runtime in `mod_main._register_locker_item()` via `load(path)`
- Registered via `ItemService.add_mod_item()` — appears in item arrays but NOT shop tiers

### Edge Cases to Handle
- Player tries to set aside while locker is full → button hidden (not shown)
- Player tries to retrieve but no free slot → button hidden
- Locker weapon is lost if the player dies in a run (standard Brotato run-end cleanup handles this)
- 4-player support: each player has their own locker slot (array indexed by player_index)
- Trading the locker item between players: blocked (item flagged non-tradeable)
