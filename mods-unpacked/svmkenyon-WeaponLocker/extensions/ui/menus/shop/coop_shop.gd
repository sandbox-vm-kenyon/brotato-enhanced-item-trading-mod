extends CoopShop


func _ready():
	._ready()
	for player_index in RunData.get_player_count():
		var item_popup = _get_item_popup(player_index)
		item_popup.connect("weapon_locker_store_pressed", self, "_on_weapon_locker_store_pressed")
		item_popup.connect("weapon_locker_retrieve_pressed", self, "_on_weapon_locker_retrieve_pressed")


func _on_weapon_locker_store_pressed(weapon_data: WeaponData, player_index: int) -> void:
	RunData.remove_weapon(weapon_data, player_index)
	RunData.set_locker_weapon(weapon_data, player_index)

	_popup_manager.reset_focus(player_index)
	_get_shop_items_container(player_index).reload_shop_items()
	_get_coop_player_container(player_index).on_hide_focused_inventory_popup()
	var gear = _get_gear_container(player_index)
	gear.set_weapons_data(RunData.get_player_weapons(player_index))
	gear.weapons_container.focus_element_index(0)
	_update_stats(player_index)

	SoundManager.play(Utils.get_rand_element(recycle_sounds), 0, 0.1, true)


func _on_weapon_locker_retrieve_pressed(player_index: int) -> void:
	var weapon_data = RunData.get_locker_weapon(player_index)
	if weapon_data == null:
		return
	RunData.add_weapon(weapon_data, player_index)
	RunData.clear_locker_weapon(player_index)

	_popup_manager.reset_focus(player_index)
	_get_shop_items_container(player_index).reload_shop_items()
	_get_coop_player_container(player_index).on_hide_focused_inventory_popup()
	var gear = _get_gear_container(player_index)
	gear.set_weapons_data(RunData.get_player_weapons(player_index))
	gear.weapons_container.focus_element_index(0)
	_update_stats(player_index)

	SoundManager.play(Utils.get_rand_element(recycle_sounds), 0, 0.1, true)
