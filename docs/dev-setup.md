# Development Environment Setup

## Tools Required

| Tool | Version | Purpose | Download |
|------|---------|---------|----------|
| GodotSteam | 3.6 (g36-s161-gs328) | Run/edit the decompiled game | https://codeberg.org/godotsteam/godotsteam/releases/tag/v3.28/ |
| GDRETools | latest | Decompile Brotato.pck | https://github.com/bruvzg/gdsdecomp/releases |
| Brotato (Steam) | 0.6.1.6+ | Source game files | Steam |
| VS Code + godot-tools | latest | Code editor | marketplace.visualstudio.com |

## Step-by-Step

### 1. Decompile Brotato
1. Install Brotato on Steam (modding branch not needed for decompile)
2. Open GDRETools → RE Tools → Recover Project
3. Navigate to your Brotato install folder, double-click `Brotato.pck`
4. Set destination to a folder like `C:\Mods\Brotato\BrotatoExport`
5. Click Extract — two passes (files + resource conversion)

### 2. Copy steam_data.json
Copy `steam_data.json` from the Brotato install folder into the root of your decompiled project. Without this the project won't run in Godot.

### 3. Open in GodotSteam
Launch `godotsteam.36.editor.windows.64.exe`, click Import, navigate to `project.godot` in your export folder.

### 4. Add mods-unpacked folder
In the project root, create `mods-unpacked/`. Clone this repo's `mods-unpacked/` contents into it.

### 5. Run
Press F5 (or the play button). The game should boot with this mod loaded.

### 6. Test trading
Use DebugService (double-click `debug_service.tscn` in Filesystem tab) to:
- Enable 2-player coop
- Enable "Disable Saving" to avoid corrupting save files
- Give yourself weapons of various tiers to test trading

## Mod ZIP Structure (for Workshop upload)
```
EnhancedItemTrading.zip
├── .import/          ← only if custom PNG assets used
└── mods-unpacked/
    └── sandbox-vm-kenyon-EnhancedItemTrading/
        └── ...
```

## Publishing to Workshop
1. Switch Brotato to modding branch in Steam → Properties → Betas
2. Launch uploader from Steam (not by double-clicking the EXE)
3. Set Workshop ID if updating an existing item
4. Mod must be "Hidden" by default after first publish — manually set to Public after upload
