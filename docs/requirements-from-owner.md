# Requirements / Blockers — Needs Input from Owner

Last updated: 2026-06-21

## ALL RESOLVED — Mod is packaged and ready to publish

---

### 1. Brotato Game Files — RESOLVED
Brotato was installed via Steam (your credentials, rhaylor) and decompiled using GDRETools v2.5.0 directly on the sandbox VM. The decompiled source is at `~/brotato-decompiled/` on the VM. All API names have been verified against the live game code.

### 2. Locker Item Art — RESOLVED
Owner confirmed: AI-generated art is OK. Icon generated at 512×512 PNG matching Brotato's bold cartoony style: dark metal locker with gold bands, hinges, keyhole latch, and a red weapon silhouette. Located at:
`items/locker/item_locker_eit.png`

### 3. Steam Workshop Publishing — RESOLVED (action on your end)
Owner confirmed: publish via your own Steam account (rhaylor). Packaged mod ZIP is at:
`dist/sandbox-vm-kenyon-EnhancedItemTrading-v0.1.0.zip`

**To publish (run on your Windows machine with Brotato installed):**
1. Right-click Brotato in Steam → Properties → Betas → select `moddingapi` branch
2. Launch Brotato once to verify the modding branch is running
3. Download the mod ZIP, extract to:
   `<Brotato install dir>/mods-unpacked/sandbox-vm-kenyon-EnhancedItemTrading/`
4. Use the in-game **Mod Publisher** (main menu → Workshop → Publish) or the standalone
   `ModTool` if the modding guide's uploader is available
5. Fill in title "Enhanced Item Trading", description (see below), and upload
6. Set visibility to Public once ready

**Suggested Workshop description:**
```
Fixes weapon trading for ALL tiers (original Coop Trading mod breaks on tier 2+ weapons), and adds a personal Weapon Locker item for each player.

• Trade weapons and items between players in co-op
• "Set Aside in Locker" — park one weapon to free up a slot for trading/buying
• "Get [Weapon] from Locker" — retrieve it when you have a free slot again
• Works with all weapon tiers (bug fix vs original mod)
• Locker appears as a starting item in every co-op run

Incompatible with: RobocrafterLP-Trade (Coop Trading)
```

### 4. Locker Scope — RESOLVED
Owner decision: **multiplayer (coop) only**. The locker is only given to players when there are 2+ players in the run. Solo players do not receive the locker item. This is already implemented (`is_locker_in_solo = false` by default).

---

## NICE TO HAVE (can be addressed post-launch)

### 5. Mod Options Integration
Currently the "Trade items over limit" toggle is wired up via dami-ModOptions (inherited from original mod). Locker can be toggled via `is_locker_enabled`. Can expose more options in a future update.

### 6. Weapon Restrictions for Locker
Implemented as recommended: no restriction on storing a weapon in the locker. Character restrictions (no melee/ranged) apply at retrieval time, same as trading.

### 7. Translations
EN, DE, RU translations exist for all locker strings in:
`translations/sandbox-vm-kenyon-EnhancedItemTrading.csv`
DE and RU strings were auto-translated as a starting point and may need native review.
