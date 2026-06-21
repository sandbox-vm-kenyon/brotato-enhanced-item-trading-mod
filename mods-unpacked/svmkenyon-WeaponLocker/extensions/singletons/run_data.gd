extends "res://singletons/run_data.gd"

var locker_weapons = {}


func add_starting_items_and_weapons() -> void:
	locker_weapons = {}
	.add_starting_items_and_weapons()
	if not is_coop_run:
		return
	var locker_item = null
	for item in ItemService.items:
		if item.my_id == "item_locker_wl":
			locker_item = item
			break
	if locker_item == null:
		return
	for player_index in get_player_count():
		add_item(locker_item, player_index)


func get_locker_weapon(player_index: int):
	return locker_weapons.get(player_index, null)


func set_locker_weapon(weapon_data: WeaponData, player_index: int) -> void:
	locker_weapons[player_index] = weapon_data


func clear_locker_weapon(player_index: int) -> void:
	locker_weapons.erase(player_index)


func has_locker_item(player_index: int) -> bool:
	for item in get_player_items(player_index):
		if item.my_id == "item_locker_wl":
			return true
	return false
