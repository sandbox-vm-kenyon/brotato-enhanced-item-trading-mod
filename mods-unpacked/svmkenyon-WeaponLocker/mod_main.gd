extends Node

const MOD_ID = "svmkenyon-WeaponLocker"
const MOD_LOG = MOD_ID + ":Main"

var mod_dir_path := ""
var extensions_dir_path := ""


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(MOD_ID)
	extensions_dir_path = mod_dir_path.plus_file("extensions")

	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/run_data.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/menus/shop/coop_item_popup.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("ui/menus/shop/coop_shop.gd"))

	var translation_path = mod_dir_path.plus_file("translations/WeaponLocker.en.translation")
	if File.new().file_exists(translation_path):
		ModLoaderMod.add_translation(translation_path)


func _ready() -> void:
	ModLoaderLog.info("Ready!", MOD_LOG)
	var ContentLoader = get_node("/root/ModLoader/Darkly77-ContentLoader/ContentLoader")
	ContentLoader.load_data(
		mod_dir_path.plus_file("content/locker_content.tres"),
		MOD_ID
	)
