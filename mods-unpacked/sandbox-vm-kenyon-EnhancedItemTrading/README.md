# Enhanced Item Trading

Fixes weapon trading for all tiers and adds a personal Weapon Locker for each player in co-op.

## Requirements

- **Brotato** on the `moddingapi` Steam beta branch
  (Steam → right-click Brotato → Properties → Betas → select `moddingapi`)

## Optional

- **[dami-ModOptions](https://steamcommunity.com/sharedfiles/filedetails/?id=2944608034)** — adds an in-game settings panel. Not required; the mod works without it using default settings.
  > **Note:** dami-ModOptions has a known crash when entering co-op shop. If you experience all mods unloading after entering co-op, unsubscribe from dami-ModOptions.

## Incompatible With

- **Coop Trading** (RobocrafterLP-Trade) — this mod replaces it. Unsubscribe from Coop Trading before using this one.

## Features

### Bug Fix: Weapon Trading (All Tiers)
The original Coop Trading mod breaks when trying to trade tier 2+ weapons. This mod fixes that — all weapon tiers can be traded freely.

### Weapon Locker
Each player starts every co-op run with a Locker item in their inventory.

- **Set a weapon aside:** Right-click any weapon → "Set Aside in Locker" — stores it temporarily
- **Retrieve it:** Right-click the Locker item → "Get [weapon name] from Locker" — returns the weapon when you have a free slot
- Only available in co-op (2+ players)
- One weapon per locker, one locker per player

## Installation

Subscribe on Steam Workshop — no manual steps needed.

If installing manually: place the `sandbox-vm-kenyon-EnhancedItemTrading` folder inside your game's `mods-unpacked/` directory.
