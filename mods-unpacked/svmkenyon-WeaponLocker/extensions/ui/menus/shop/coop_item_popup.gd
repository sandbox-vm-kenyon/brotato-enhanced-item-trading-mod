extends CoopItemPopup

signal weapon_locker_store_pressed(weapon_data, player_index)
signal weapon_locker_retrieve_pressed(player_index)

var _store_button = null
var _retrieve_button = null


func _ready():
	if RunData.get_player_count() <= 1:
		return
	var btn_container = _cancel_button.get_parent()

	_store_button = _discard_button.duplicate()
	_store_button.text = tr("WL_STORE_BUTTON")
	_store_button.connect("pressed", self, "_on_store_pressed")
	btn_container.add_child(_store_button)
	btn_container.move_child(_store_button, _cancel_button.get_index())
	_store_button.hide()

	_retrieve_button = _discard_button.duplicate()
	_retrieve_button.connect("pressed", self, "_on_retrieve_pressed")
	btn_container.add_child(_retrieve_button)
	btn_container.move_child(_retrieve_button, _cancel_button.get_index())
	_retrieve_button.hide()


func should_show_buttons(item_data, focused) -> bool:
	if item_data is ItemData and item_data.my_id == "item_locker_wl":
		return buttons_enabled and focused
	return .should_show_buttons(item_data, focused)


func _update_button_visibilities() -> void:
	if _item_data is ItemData and _item_data.my_id == "item_locker_wl":
		_combine_button.hide()
		_combine_button.focus_mode = FOCUS_NONE
		_discard_button.hide()
		_discard_button.focus_mode = FOCUS_NONE
		if _store_button:
			_store_button.hide()
		if _focused:
			_cancel_button.show()
			_cancel_button.focus_mode = FOCUS_ALL
			if _retrieve_button:
				var stored = RunData.get_locker_weapon(player_index)
				if stored != null and RunData.get_free_weapon_slots(player_index) > 0:
					_retrieve_button.text = tr("WL_RETRIEVE_PREFIX") + " " + tr(stored.name) + " " + tr("WL_RETRIEVE_SUFFIX")
					_retrieve_button.show()
					_retrieve_button.focus_mode = FOCUS_ALL
				else:
					_retrieve_button.hide()
		else:
			_cancel_button.show()
			_cancel_button.focus_mode = FOCUS_NONE
			if _retrieve_button:
				_retrieve_button.hide()
		return

	._update_button_visibilities()

	if _store_button == null:
		return
	_store_button.hide()
	_store_button.focus_mode = FOCUS_NONE
	if _item_data is WeaponData and _focused:
		if RunData.has_locker_item(player_index) and RunData.get_locker_weapon(player_index) == null:
			_store_button.show()
			_store_button.focus_mode = FOCUS_ALL


func hide(_player_index: int = -1) -> void:
	.hide(_player_index)
	if _store_button:
		_store_button.hide()
	if _retrieve_button:
		_retrieve_button.hide()


func _on_store_pressed() -> void:
	if not (_item_data is WeaponData):
		return
	emit_signal("weapon_locker_store_pressed", _item_data, player_index)
	_focused = false


func _on_retrieve_pressed() -> void:
	emit_signal("weapon_locker_retrieve_pressed", player_index)
	_focused = false
