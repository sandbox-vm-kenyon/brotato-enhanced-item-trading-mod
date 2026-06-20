extends "res://singletons/run_data.gd"

const MOD_ID = "sandbox-vm-kenyon-EnhancedItemTrading"
const CONFIG_TRADE_OVER_LIMIT = "TRADE_ITEMS_OVER_LIMIT"
const CONFIG_ENABLE_LOCKER = "ENABLE_LOCKER"
const CONFIG_LOCKER_IN_SOLO = "LOCKER_IN_SOLO"

var eit_config: ModConfig
var is_trade_items_over_limit: bool = false
var is_locker_enabled: bool = true
var is_locker_in_solo: bool = false

# One locker slot per player (null = empty, WeaponData = weapon stored)
var locker_weapons: Array = [null, null, null, null]


func _ready():
	var ModsConfigInterface = get_node("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	if ModsConfigInterface != null:
		ModsConfigInterface.connect("setting_changed", self, "_on_eit_setting_changed")

	eit_config = ModLoaderConfig.get_current_config(MOD_ID)
	if eit_config != null:
		_apply_config(eit_config.data)


func _apply_config(data: Dictionary) -> void:
	if CONFIG_TRADE_OVER_LIMIT in data:
		is_trade_items_over_limit = data[CONFIG_TRADE_OVER_LIMIT]
	if CONFIG_ENABLE_LOCKER in data:
		is_locker_enabled = data[CONFIG_ENABLE_LOCKER]
	if CONFIG_LOCKER_IN_SOLO in data:
		is_locker_in_solo = data[CONFIG_LOCKER_IN_SOLO]


func _on_eit_setting_changed(setting_name: String, value, _mod_name: String) -> void:
	var config = ModLoaderConfig.get_current_config(MOD_ID)
	match setting_name:
		CONFIG_TRADE_OVER_LIMIT:
			is_trade_items_over_limit = value
			if config != null:
				config.data[CONFIG_TRADE_OVER_LIMIT] = value
		CONFIG_ENABLE_LOCKER:
			is_locker_enabled = value
			if config != null:
				config.data[CONFIG_ENABLE_LOCKER] = value
		CONFIG_LOCKER_IN_SOLO:
			is_locker_in_solo = value
			if config != null:
				config.data[CONFIG_LOCKER_IN_SOLO] = value


# --- Locker API ---

func get_locker_weapon(player_index: int):
	if player_index < 0 or player_index >= locker_weapons.size():
		return null
	return locker_weapons[player_index]

func set_locker_weapon(player_index: int, weapon_data) -> void:
	if player_index < 0 or player_index >= locker_weapons.size():
		return
	locker_weapons[player_index] = weapon_data

func clear_locker_weapon(player_index: int) -> void:
	set_locker_weapon(player_index, null)

func has_locker_weapon(player_index: int) -> bool:
	return get_locker_weapon(player_index) != null

func is_locker_slot_open(player_index: int) -> bool:
	return not has_locker_weapon(player_index)


# --- Trading helpers ---

func is_can_trade_item(object_data, player_index: int) -> bool:
	if is_trade_items_over_limit:
		return true
	if object_data is ItemData:
		var remaining = get_remaining_max_nb_item(object_data, player_index)
		return remaining > 0 or remaining == -1
	return false

# Check if a weapon can be received by a player via trade (not shop-buy logic).
# This bypasses has_weapon_slot_available which only works for shop purchases.
func can_receive_traded_weapon(weapon_data: WeaponData, player_index: int) -> bool:
	var weapons = get_player_weapons(player_index)
	var max_nb = get_player_max_nb_weapons(player_index)

	# Free slot available — can receive directly.
	if weapons.size() < max_nb:
		return true

	# No free slot — check if player has the tier-below version of this weapon.
	# In that case receiving it will trigger an in-place upgrade (same slot consumed).
	if weapon_data.tier > 1:
		for existing in weapons:
			if existing.weapon_id == weapon_data.weapon_id and existing.tier == weapon_data.tier - 1:
				return true

	return false

# Returns how many free weapon slots a player has (used for locker retrieval check).
func get_free_weapon_slots(player_index: int) -> int:
	var weapons = get_player_weapons(player_index)
	var max_nb = get_player_max_nb_weapons(player_index)
	return max(0, max_nb - weapons.size())
