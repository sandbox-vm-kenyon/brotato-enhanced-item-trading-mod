# Requirements / Blockers — Needs Input from Owner

Last updated: 2026-06-20

## REQUIRED before mod can be tested/built

### 1. Brotato Game Files (CRITICAL)
The modding workflow requires decompiling the game's `Brotato.pck` using GDRETools to get the vanilla source. This is the foundation for everything — without it, we cannot:
- Verify the exact API names of RunData methods (e.g. `get_player_max_nb_weapons`, `has_weapon_slot_available`)
- Run the mod in Godot to test it
- Know if any vanilla function signatures changed in recent game updates

**What we need:** Either:
- (a) Share the decompiled Brotato project folder (zipped, private) via Google Drive / similar. The guide says **do not share publicly** — a private share to this collaborator is fine.
- (b) Provide SSH/remote access to a Windows machine with Brotato installed so we can run GDRETools and Godot there.
- (c) Tell us the Brotato version you're running so we can at least verify which API version applies.

### 2. Locker Item Art Asset
We need a small icon for the Locker item (shown in the player's inventory panel). Ideal: 512×512 PNG, similar art style to vanilla Brotato items (simple, bold, slightly cartoony).

**What we need:** Either provide art, or confirm it's OK to use a placeholder box/crate icon for now and polish later.

### 3. Steam Account for Workshop Publishing
Publishing to the Steam Workshop requires:
- A Steam account that has spent at least $5 USD
- Phone number verification

We have the sandbox VM's Protonmail (`sandbox-vm-kenyon@proton.me`) ready. We can create the Steam account and go through email verification. However:

**What we need:**
- Permission to use a credit card or purchase to meet the $5 Steam spending requirement (we cannot spend money without authorization)
- OR: use your own Steam account to publish, and we'll hand you the packaged mod ZIP

### 4. Which Characters Should Start with the Locker?
The locker is given to all players at run start. Should it be:
- (a) **All characters** — every coop run starts with the locker (recommended for simplicity)
- (b) **Opt-in via Mod Options** — players can toggle the locker on/off
- (c) **Only in coop** — locker only appears in 2+ player games (since solo play has no trading partner)

## NICE TO HAVE (can decide later)

### 5. Mod Options Integration
The original mod has a "Trade items over limit" toggle via dami-ModOptions. Should we:
- Keep that toggle and add more options (e.g. "Enable locker", "Max locker size = 1/2/3")
- Keep it simple — no options, everything on by default

### 6. Weapon Restrictions for Locker
Should locked weapons still obey character restrictions (e.g. a character that can't use ranged weapons can't put a ranged weapon in the locker)?
- Recommend: No restriction on locker storage — the locker is a physical slot, not a use slot. The weapon just sits there. Restriction applies when retrieving (if the character couldn't use the weapon, it still can't, same as normal trading).

### 7. Translations
The original mod has EN/DE/RU. Should we add those same languages for the new locker strings? We can auto-translate the new strings into DE and RU as a starting point.
