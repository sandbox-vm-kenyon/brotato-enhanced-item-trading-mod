extends Node

const MOD_ID = "sandbox-vm-kenyon-EnhancedItemTrading"
const MOD_DIR := MOD_ID
const MOD_LOG := MOD_ID + ":Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(MOD_DIR)
	install_script_extensions()
	add_translations()

func _ready() -> void:
	ModLoaderLog.info("Ready!", MOD_LOG)
	_config(MOD_ID, MOD_LOG)


func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.plus_file("extensions")

	var extensions = [
		"singletons/run_data.gd",
		"singletons/debug_service.gd",
		"ui/menus/shop/coop_item_popup.gd",
	]

	for extension in extensions:
		ModLoaderMod.install_script_extension(extensions_dir_path.plus_file(extension))

func add_translations() -> void:
	translations_dir_path = mod_dir_path.plus_file("translations")

	var translations = ["en", "ru", "de"]

	for translation in translations:
		var path = translations_dir_path.plus_file("sandbox-vm-kenyon-EnhancedItemTrading.%s.translation" % translation)
		if File.new().file_exists(path):
			ModLoaderMod.add_translation(path)

func _config(mod_id: String, mod_log: String) -> void:
	var data = ModLoaderStore.mod_data[mod_id]
	if data == null:
		return

	var version = data.manifest.version_number
	ModLoaderLog.info("Version %s" % version, mod_log)
	var config = ModLoaderConfig.get_config(mod_id, version)

	if config == null:
		var default_config = ModLoaderConfig.get_default_config(mod_id)
		if default_config != null:
			config = ModLoaderConfig.create_config(mod_id, version, default_config.data)
		else:
			config = ModLoaderConfig.create_config(mod_id, version, {})

	if config != null and ModLoaderConfig.get_current_config_name(mod_id) != version:
		ModLoaderConfig.set_current_config(config)
		if config.is_valid():
			config.save_to_file()
