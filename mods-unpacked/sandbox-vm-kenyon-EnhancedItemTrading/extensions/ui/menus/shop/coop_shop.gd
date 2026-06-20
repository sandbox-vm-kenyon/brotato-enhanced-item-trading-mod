extends CoopShop

# Enhanced Item Trading — coop_shop.gd extension
# Fix: replaces shop-specific _can_weapon_be_bought with a trade-safe check
# that works for all weapon tiers by testing free slots directly.

func _ready():
	var player_count: int = RunData.get_player_count()

	for player_index in player_count:
		var item_popup = _get_item_popup(player_index)
		item_popup.connect("weapon_trade_button_pressed_eit", self, "on_weapon_trade_button_pressed_eit")
		item_popup.connect("item_trade_button_pressed_eit", self, "on_item_trade_button_pressed_eit")
		item_popup.connect("weapon_locker_set_aside_pressed_eit", self, "on_weapon_locker_set_aside_pressed_eit")
		item_popup.connect("weapon_locker_retrieve_pressed_eit", self, "on_weapon_locker_retrieve_pressed_eit")


# --- Trade: weapons ---

func on_weapon_trade_button_pressed_eit(weapon_data: WeaponData, from_player_index: int, to_player_index: int) -> void:
	if not _can_weapon_be_traded_eit(weapon_data, to_player_index):
		_play_fail_sound()
		return

	_check_character_restrictions(weapon_data, to_player_index)
	process_player_weapons_inventory(weapon_data, from_player_index)
	.buy_weapon(weapon_data, to_player_index)
	SoundManager.play(Utils.get_rand_element(recycle_sounds), 0, 0.1, true)


# --- Trade: items ---

func on_item_trade_button_pressed_eit(item_data: ItemData, from_player_index: int, to_player_index: int) -> void:
	var no_trade_items = ["item_celery_tea", "item_lure", "item_peacock"]
	if no_trade_items.has(item_data.my_id):
		return

	if not RunData.is_can_trade_item(item_data, to_player_index):
		_play_fail_sound()
		return

	process_player_items_inventory(item_data, from_player_index)
	.buy_item(item_data, to_player_index)
	SoundManager.play(Utils.get_rand_element(recycle_sounds), 0, 0.1, true)


# --- Locker: set aside ---

func on_weapon_locker_set_aside_pressed_eit(weapon_data: WeaponData, player_index: int) -> void:
	if not RunData.is_locker_slot_open(player_index):
		_play_fail_sound()
		return

	RunData.set_locker_weapon(player_index, weapon_data)
	process_player_weapons_inventory(weapon_data, player_index)
	SoundManager.play(Utils.get_rand_element(recycle_sounds), 0, 0.1, true)
	ModLoaderLog.info("Player %s set aside %s in locker" % [player_index, weapon_data.my_id], "EIT")


# --- Locker: retrieve ---

func on_weapon_locker_retrieve_pressed_eit(player_index: int) -> void:
	var stored_weapon = RunData.get_locker_weapon(player_index)
	if stored_weapon == null:
		_play_fail_sound()
		return

	if RunData.get_free_weapon_slots(player_index) <= 0:
		_play_fail_sound()
		return

	RunData.clear_locker_weapon(player_index)
	.buy_weapon(stored_weapon, player_index)
	SoundManager.play(Utils.get_rand_element(recycle_sounds), 0, 0.1, true)
	ModLoaderLog.info("Player %s retrieved %s from locker" % [player_index, stored_weapon.my_id], "EIT")


# --- Core fix: trade-safe weapon eligibility ---
# Unlike the vanilla _can_weapon_be_bought, this does NOT use has_weapon_slot_available.
# has_weapon_slot_available checks shop buy-path eligibility (upgrade chains from tier 1),
# which returns false for tier 2+ weapons even when a free slot exists.

func _can_weapon_be_traded_eit(weapon_data: WeaponData, player_index: int) -> bool:
	# Character-level restrictions still apply.
	var no_melee = RunData.get_player_effect_bool("no_melee_weapons", player_index)
	var no_ranged = RunData.get_player_effect_bool("no_ranged_weapons", player_index)
	var no_dupes = RunData.get_player_effect_bool("no_duplicate_weapons", player_index)
	var lock_current = RunData.get_player_effect_bool("lock_current_weapons", player_index)

	if no_melee and weapon_data.type == WeaponType.MELEE:
		return false
	if no_ranged and weapon_data.type == WeaponType.RANGED:
		return false

	var weapons = RunData.get_player_weapons(player_index)

	if no_dupes:
		if weapon_data.weapon_id in RunData.get_unique_weapon_ids(player_index):
			return false

	if lock_current:
		# Can only replace via upgrade, not add new.
		return RunData.can_receive_traded_weapon(weapon_data, player_index)

	# Main slot check — works for all tiers.
	return RunData.can_receive_traded_weapon(weapon_data, player_index)


func _check_character_restrictions(_weapon_data: WeaponData, _player_index: int) -> void:
	pass


func _play_fail_sound() -> void:
	SoundManager.play(Utils.get_rand_element(Player.new().hurt_sounds), 0, 0.0, true)


# Inventory processing — same as original mod

func process_player_items_inventory(item_data: ItemData, player_index: int):
	_popup_manager.reset_focus(player_index)
	_update_stats(player_index)
	RunData.remove_item(item_data, player_index, false)
	_get_shop_items_container(player_index).reload_shop_items()
	_get_coop_player_container(player_index).on_hide_focused_inventory_popup()
	var gear = _get_gear_container(player_index)
	gear.set_items_data(RunData.get_player_items(player_index))
	gear.items_container.focus_element_index(0)

func process_player_weapons_inventory(weapon_data: WeaponData, player_index: int):
	_popup_manager.reset_focus(player_index)
	_update_stats(player_index)
	RunData.remove_weapon(weapon_data, player_index)
	_get_shop_items_container(player_index).reload_shop_items()
	_get_coop_player_container(player_index).on_hide_focused_inventory_popup()
	var gear = _get_gear_container(player_index)
	gear.set_weapons_data(RunData.get_player_weapons(player_index))
	gear.items_container.focus_element_index(0)
