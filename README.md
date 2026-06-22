# Brotato Modding — Weapon Fix & Weapon Locker

This repo contains two standalone Brotato coop mods, plus all build artifacts and deployment scripts.

---

## Mods

### 1. Coop Trading Tier Fix (`dist/RobocrafterLP-Trade-with-tier-fix.zip`)

**Workshop:** still using the original RobocrafterLP-Trade slot (ID `3365699088`)  
**Mod ID:** `RobocrafterLP-Trade` (unchanged from original)

A minimal patch on top of the confirmed-working [Coop Trading mod by RobocrafterLP & Zeerck](https://steamcommunity.com/sharedfiles/filedetails/?id=3365699088). The original mod could not trade weapons above tier 1.

**Only one file changed from the original: `coop_shop.gd`**

- Replaced `_can_weapon_be_bought()` (which filters by `min_weapon_tier` / `max_weapon_tier`) with `_can_weapon_be_traded()`, which removes the tier range check entirely.
- Replaced `.buy_weapon()` (shop-specific upgrade-path logic) with `_give_weapon_direct()`, which calls `RunData.add_weapon()` directly and handles combining when no free slot is available.

---

### 2. Weapon Locker (`mods-unpacked/svmkenyon-WeaponLocker/`)

**Workshop ID:** `3749293112`  
**Mod ID:** `svmkenyon-WeaponLocker`  
**Depends on:** `Darkly77-ContentLoader`

A new standalone mod. Each player in a coop run gets a **Weapon Locker** item in their inventory at run start (not buyable in shops, not recyclable, max 1 per player).

**How it works:**
- Click a weapon in your inventory popup → "Store in Locker" button appears (if your locker is empty).
- Click the Locker item in your inventory → "Get [weapon name] from Locker" appears (if the locker holds a weapon and you have a free weapon slot).
- Locker state is per-player, stored in a `RunData` extension. It resets at the start of each new run.

**Purpose:** lets players temporarily free a weapon slot to facilitate trading or shop purchases, without selling or combining.

---

## Lessons Learned

### 1. Always start from the confirmed-working baseline ZIP, not from source found elsewhere

The Workshop ZIP file is the ground truth. GitHub mirrors and extracted sources can be out of date or differ from what actually runs. We wasted significant time building on a stale source instead of the ZIP at `steamapps/workshop/content/1942280/<id>/`.

### 2. ModLoader 6.x rejects namespaces with hyphens

`manifest.json` namespace must contain only letters, numbers, and underscores. `"sandbox-vm-kenyon"` is invalid and causes a `FATAL-ERROR` that silently allows the mod to partially load but breaks config schema registration. Use `"svmkenyon"` or similar.

### 3. Script extensions must chain `._ready()` when the parent's `_ready()` does meaningful setup

If the parent class does node setup in `_ready()` (like `CoopShop` does with `_find_nodes()`), your extension must call `._ready()` first. Skipping it produces null-reference crashes at runtime, not at load time, making it hard to diagnose.

### 4. `debug_service.gd` in the original mod contains hardcoded mod folder paths

The original Coop Trading mod's `debug_service.gd` calls `ModLoaderMod.install_script_extension()` with a hardcoded `"RobocrafterLP-Trade/..."` path. When the mod is renamed, those paths break and ModLoader throws `"RobocrafterLP-Trade is an invalid mod_id"`. Always audit every `.gd` file for hardcoded mod IDs when forking a mod.

### 5. `buy_weapon()` is shop-specific; use `RunData.add_weapon()` for trades

`buy_weapon()` contains upgrade-path logic gated on `min_weapon_tier` / `max_weapon_tier`. Calling it for a trade (where the weapon already exists and tiers don't apply in the same way) causes tier 2+ weapons to be silently rejected. `RunData.add_weapon()` bypasses all shop logic and is the right call for non-purchase weapon grants.

### 6. Deleting save files locally does not fix Steam Cloud corruption

Steam re-downloads deleted save files. To fix a corrupted save (e.g. one that records a mod ID that no longer exists), either edit the save file directly to remove the stale mod reference, or use Steam's "Delete Cloud Save" option from the game's Steam properties page before deleting locally.

### 7. Keep mods small and single-purpose

Building the tier fix and the locker as one combined mod made every bug harder to diagnose — it was impossible to tell whether a crash came from the trade fix code or the locker code. As separate mods, each can be enabled or disabled independently for testing.

---

## How We Deploy Without the Brotato Mod Uploader

The built-in Brotato mod upload tool does not work on Linux. We use `steamcmd` directly.

### Steps

1. **Build the ZIP** with the correct structure:
   ```
   mods-unpacked/<mod-folder>/
   ```
   The root of the ZIP must be `mods-unpacked/`, not the mod folder itself.

2. **Put the ZIP in a dedicated upload folder.** ModLoader scans each Workshop item folder for `.zip` files — it will not load a raw folder structure. The `contentfolder` in the VDF must point to a directory whose only content is the mod ZIP:
   ```bash
   mkdir -p /tmp/my-upload-content
   cp dist/my-mod.zip /tmp/my-upload-content/
   ```

3. **Create a VDF file** describing the Workshop item:
   ```
   "workshopitem"
   {
       "appid"           "1942280"
       "publishedfileid" "0"          ← use "0" to create new, or the existing ID to update
       "contentfolder"   "/absolute/path/to/folder/to/upload"
       "previewfile"     "/absolute/path/to/preview.png"
       "visibility"      "0"          ← 0=public, 1=friends only, 2=private
       "title"           "Mod Title"
       "description"     "Mod description."
       "changenote"      "What changed in this version."
   }
   ```
   Note: `contentfolder` is the folder whose **contents** are uploaded — not the folder itself. Point it at the `mods-unpacked/` directory so the mod folder ends up at the root of the Workshop item.

4. **Run steamcmd:**
   ```bash
   steamcmd +login <username> <password> +workshop_build_item /path/to/item.vdf +quit
   ```

5. **Get the new Workshop ID** from the output line:
   ```
   Create new workshop item ( PublishFileID 3749293112).
   ```

6. **For future updates**, replace `"publishedfileid" "0"` with the actual ID so it updates instead of creating a new item. The VDF at `/tmp/wl-workshop-item.vdf` is already updated with the correct ID after the first upload.

7. **Set Workshop dependencies manually after upload.** Listing a mod in `manifest.json` `"dependencies"` tells ModLoader to enforce the dependency at load time, but it does **not** automatically set the dependency relationship on the Steam Workshop item page. You must go to the Workshop item page → Edit → "Add/Remove Required Items" and add each dependency there. Without this, users who subscribe to your mod will not have the dependency automatically downloaded by Steam. This step cannot be done via steamcmd — it requires logging into the Steam website or the Steam client as the item owner.

---

## Repo Structure

```
dist/                                    ← packaged ZIPs ready for upload
  RobocrafterLP-Trade-with-tier-fix.zip  ← tier fix (upload to original Workshop slot)
  svmkenyon-WeaponLocker-v0.1.0.zip      ← weapon locker (Workshop ID 3749293112)

mods-unpacked/
  svmkenyon-WeaponLocker/                ← weapon locker mod source
    manifest.json
    mod_main.gd
    content/locker_content.tres
    items/item_locker_wl_data.tres
    extensions/singletons/run_data.gd
    extensions/ui/menus/shop/coop_item_popup.gd
    extensions/ui/menus/shop/coop_shop.gd
    translations/WeaponLocker.en.csv
```
