extends "res://singletons/debug_service.gd"

const MOD_DIR = "sandbox-vm-kenyon-EnhancedItemTrading"

func _ready():
	var unpacked = ModLoaderMod.get_unpacked_dir()
	ModLoaderMod.install_script_extension(unpacked.plus_file(MOD_DIR + "/extensions/ui/menus/shop/coop_item_popup.gd"))
	ModLoaderMod.install_script_extension(unpacked.plus_file(MOD_DIR + "/extensions/ui/menus/shop/coop_shop.gd"))
	ModLoaderMod.install_script_extension(unpacked.plus_file(MOD_DIR + "/extensions/ui/menus/ingame/coop_upgrades_ui_player_container.gd"))
	ModLoaderMod.install_script_extension(unpacked.plus_file(MOD_DIR + "/extensions/ui/menus/ingame/upgrades_ui.gd"))
