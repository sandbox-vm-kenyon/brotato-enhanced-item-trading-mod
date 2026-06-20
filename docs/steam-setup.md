# Steam Setup on the Sandbox VM

## Status
Steam installed via apt on Ubuntu 22.04 (i386 package, multi-arch enabled).

## Account
- Email: sandbox-vm-kenyon@proton.me
- **BLOCKER:** Steam account not yet created — requires browser login to Protonmail for email verification, plus $5 USD spend and phone number for Workshop publishing rights.

## Notes
- Steam GUI requires a display; run with `DISPLAY=:0 steam` if X11/Xvfb is running.
- The Brotato Workshop uploader tool (GodotWorkshopUtility.exe) is Windows-only — it must be run on the owner's machine with Brotato installed.
- Steam on this VM is primarily useful for verifying package availability, not for running the game.

## Publishing Workflow (for owner)
1. Switch Brotato to modding branch: Steam → Brotato → Properties → Betas
2. Launch uploader from Steam (not by double-clicking EXE)
3. Zip the mod: `mods-unpacked/sandbox-vm-kenyon-EnhancedItemTrading/` → `EnhancedItemTrading.zip`
4. Use Workshop ID from existing item if updating
5. After upload, set visibility to Public on the Workshop page
