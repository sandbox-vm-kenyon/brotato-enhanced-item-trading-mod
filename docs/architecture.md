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

Note: `get_player_max_nb_weapons` API name needs verification against the decompiled source — it may be `get_player_effect("max_nb_weapons")` or similar.

We still keep the melee/ranged/duplicate restriction checks from `_can_weapon_be_bought` since those reflect real character constraints (not shop-specific logic).

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
- Vanilla start items are set in character data — we hook into `run_data.gd` to append the locker item after the run starts
- The locker will appear alongside the character icon as a standard item

### Edge Cases to Handle
- Player tries to set aside while locker is full → button hidden (not shown)
- Player tries to retrieve but no free slot → button hidden
- Locker weapon is lost if the player dies in a run (standard Brotato run-end cleanup handles this)
- 4-player support: each player has their own locker slot (array indexed by player_index)
- Trading the locker item between players: blocked (item flagged non-tradeable)
