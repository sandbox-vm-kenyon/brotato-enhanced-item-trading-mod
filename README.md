# Enhanced Item Trading — Brotato Mod

A Brotato mod that fixes weapon trading bugs from the original Coop Trading mod and adds a personal weapon locker mechanic.

**Steam mod name:** Enhanced Item Trading  
**Mod ID:** `sandbox-vm-kenyon-EnhancedItemTrading`  
**Based on:** [Coop Trading by RobocrafterLP & Zeerck](https://steamcommunity.com/sharedfiles/filedetails/?id=3365699088)

## What This Mod Does

### Fix: Weapon Trading (all tiers)
The original Coop Trading mod cannot trade weapons above tier 1. The root cause is that `_can_weapon_be_bought` uses the vanilla shop's `has_weapon_slot_available`, which checks upgrade-path eligibility rather than simply whether a free slot exists. We replace that check for trades with a direct slot-count comparison.

### New Feature: Personal Weapon Locker
Each player has a **Locker** item in their inventory from the start of the run. It holds exactly one weapon aside. The locker shows up as a normal player item (alongside the character icon).

- **Set Aside:** From the weapon action popup (same area as "Give to Player N"), a new button "Set Aside in Locker" moves the selected weapon into your locker. Your locker must be empty.
- **Retrieve:** Select the Locker item → action menu shows "Get \<WeaponName\> from Locker" if your locker holds a weapon AND you have a free weapon slot.

This lets players create a temporary free slot to facilitate trading or shop purchases without selling or combining.

## File Structure

```
mods-unpacked/sandbox-vm-kenyon-EnhancedItemTrading/
├── mod_main.gd
├── manifest.json
├── extensions/
│   ├── singletons/
│   │   └── run_data.gd
│   └── ui/menus/
│       ├── shop/
│       │   ├── coop_item_popup.gd    ← weapon trade buttons + "Set Aside" button
│       │   └── coop_shop.gd          ← trade logic, weapon slot fix
│       └── ingame/
│           ├── coop_upgrades_ui_player_container.gd
│           └── upgrades_ui.gd
├── items/
│   └── locker/
│       ├── item_locker.gd            ← locker ItemData definition
│       └── item_locker.png           ← locker icon (needs art asset)
└── translations/
    └── sandbox-vm-kenyon-EnhancedItemTrading.csv
```

## Development Setup

See [docs/dev-setup.md](docs/dev-setup.md) for full environment setup instructions (GodotSteam 3.6, GDRETools, decompiling Brotato).

## Known Blockers / Requirements from Owner

See [docs/requirements-from-owner.md](docs/requirements-from-owner.md).

## Mod Architecture Notes

See [docs/architecture.md](docs/architecture.md) for a detailed breakdown of the bug root cause, fix approach, and locker feature design.
