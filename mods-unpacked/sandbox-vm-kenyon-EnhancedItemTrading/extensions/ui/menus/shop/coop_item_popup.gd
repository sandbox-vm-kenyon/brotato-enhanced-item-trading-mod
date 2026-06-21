extends CoopItemPopup

# Enhanced Item Trading — coop_item_popup.gd extension
# Adds: trade buttons for all weapon tiers, "Set Aside in Locker" button,
#       and "Get <name> from Locker" button on the locker item.

signal weapon_trade_button_pressed_eit(weapon_data, from_player_index, to_player_index)
signal item_trade_button_pressed_eit(item_data, from_player_index, to_player_index)
signal weapon_locker_set_aside_pressed_eit(weapon_data, player_index)
signal weapon_locker_retrieve_pressed_eit(player_index)

var _trade_buttons: Array = [null, null, null, null]
var _locker_set_aside_button = null
var _locker_retrieve_button = null
var _base_button_template = null


func _is_coop() -> bool:
	return RunData.get_player_count() > 1


func _ready():
	._ready()
	_base_button_template = _cancel_button.duplicate()
	for child in _base_button_template.get_children():
		child.free()

	_build_trade_buttons()
	_build_locker_buttons()


func _build_trade_buttons() -> void:
	if not _is_coop():
		return

	var buttons_parent = _cancel_button.get_parent()
	for target_index in RunData.get_player_count():
		var btn = _base_button_template.duplicate()
		btn.text = "EIT_GIVE_TO_PLAYER_%s" % str(target_index + 1)
		btn.name = "EIT_trade_p%s" % (target_index + 1)
		btn.set_script(preload("res://ui/menus/global/my_menu_button.gd"))
		btn.add_stylebox_override("normal", _discard_button.get_stylebox("normal").duplicate())
		btn.connect("pressed", self, "_on_trade_button_pressed", [target_index])
		btn.hide()
		_trade_buttons[target_index] = btn
		buttons_parent.add_child(btn)
		buttons_parent.move_child(btn, _cancel_button.get_index() + 1)


func _build_locker_buttons() -> void:
	var buttons_parent = _cancel_button.get_parent()

	_locker_set_aside_button = _base_button_template.duplicate()
	_locker_set_aside_button.text = "EIT_SET_ASIDE_IN_LOCKER"
	_locker_set_aside_button.name = "EIT_locker_set_aside"
	_locker_set_aside_button.set_script(preload("res://ui/menus/global/my_menu_button.gd"))
	_locker_set_aside_button.add_stylebox_override("normal", _discard_button.get_stylebox("normal").duplicate())
	_locker_set_aside_button.connect("pressed", self, "_on_locker_set_aside_pressed")
	_locker_set_aside_button.hide()
	buttons_parent.add_child(_locker_set_aside_button)
	buttons_parent.move_child(_locker_set_aside_button, _cancel_button.get_index() + 1)

	_locker_retrieve_button = _base_button_template.duplicate()
	_locker_retrieve_button.text = "EIT_GET_FROM_LOCKER"
	_locker_retrieve_button.name = "EIT_locker_retrieve"
	_locker_retrieve_button.set_script(preload("res://ui/menus/global/my_menu_button.gd"))
	_locker_retrieve_button.add_stylebox_override("normal", _discard_button.get_stylebox("normal").duplicate())
	_locker_retrieve_button.connect("pressed", self, "_on_locker_retrieve_pressed")
	_locker_retrieve_button.hide()
	buttons_parent.add_child(_locker_retrieve_button)
	buttons_parent.move_child(_locker_retrieve_button, _cancel_button.get_index() + 1)


# --- Button press handlers ---

func _on_trade_button_pressed(target_index: int) -> void:
	if _item_data is WeaponData:
		emit_signal("weapon_trade_button_pressed_eit", _item_data, player_index, target_index)
	elif _item_data is ItemData:
		emit_signal("item_trade_button_pressed_eit", _item_data, player_index, target_index)


func _on_locker_set_aside_pressed() -> void:
	if _item_data is WeaponData:
		emit_signal("weapon_locker_set_aside_pressed_eit", _item_data, player_index)


func _on_locker_retrieve_pressed() -> void:
	emit_signal("weapon_locker_retrieve_pressed_eit", player_index)


# --- Visibility update ---

func display_element(element: InventoryElement) -> void:
	.display_element(element)
	_update_eit_buttons()

func focus() -> void:
	.focus()
	_update_eit_buttons()

func hide(p_player_index: int = -1) -> void:
	.hide(p_player_index)
	_update_eit_buttons()


func _update_eit_buttons() -> void:
	_update_trade_buttons()
	_update_locker_buttons()


func _update_trade_buttons() -> void:
	var show_trades = _focused and _item_data != null and _is_coop()

	for target_index in RunData.get_player_count():
		var btn = _trade_buttons[target_index]
		if btn == null:
			continue

		var is_self = (target_index == player_index)
		var is_locker_item = _item_data is ItemData and _item_data.my_id == "item_locker_eit"
		var can_show = show_trades and not is_self and not is_locker_item

		if _item_data is WeaponData:
			btn.visible = can_show
			btn.focus_mode = FOCUS_ALL if can_show else FOCUS_NONE
		elif _item_data is ItemData and not "character" in _item_data.my_id:
			btn.visible = can_show
			btn.focus_mode = FOCUS_ALL if can_show else FOCUS_NONE
		else:
			btn.hide()
			btn.focus_mode = FOCUS_NONE


func _update_locker_buttons() -> void:
	if not RunData.is_locker_enabled:
		_locker_set_aside_button.hide()
		_locker_retrieve_button.hide()
		return

	# "Set Aside" — shown when: focused, item is a weapon, locker is empty
	var can_set_aside = (
		_focused
		and _item_data is WeaponData
		and RunData.is_locker_slot_open(player_index)
	)
	_locker_set_aside_button.visible = can_set_aside
	_locker_set_aside_button.focus_mode = FOCUS_ALL if can_set_aside else FOCUS_NONE

	# "Get from Locker" — shown when: focused, item is the locker, locker has a weapon,
	# and player has a free slot
	var stored = RunData.get_locker_weapon(player_index)
	var can_retrieve = (
		_focused
		and _item_data is ItemData
		and _item_data != null
		and _item_data.my_id == "item_locker_eit"
		and stored != null
		and RunData.get_free_weapon_slots(player_index) > 0
	)
	if can_retrieve and stored != null:
		_locker_retrieve_button.text = "EIT_GET_FROM_LOCKER"  # Translation key; name filled at display time
		_locker_retrieve_button.visible = true
		_locker_retrieve_button.focus_mode = FOCUS_ALL
	else:
		_locker_retrieve_button.hide()
		_locker_retrieve_button.focus_mode = FOCUS_NONE


# --- Override vanilla button visibility so our buttons coexist cleanly ---

func should_show_buttons(item_data: ItemParentData, focused: bool) -> bool:
	if item_data is ItemData:
		return buttons_enabled and not "character" in item_data.my_id and (not RunData.is_coop_run or focused)
	elif item_data is WeaponData:
		return .should_show_buttons(item_data, focused)
	return false


func _update_button_visibilities() -> void:
	if _item_data is WeaponData:
		._update_button_visibilities()
		return
	elif _item_data is ItemData:
		var buttons := [_combine_button, _discard_button, _cancel_button]
		if _item_data == null or not should_show_buttons(_item_data, _focused):
			for button in buttons:
				if button != null:
					button.hide()
					button.focus_mode = FOCUS_NONE
			return

		for button in buttons:
			if button != _combine_button:
				button.show()
				button.focus_mode = FOCUS_ALL if _focused else FOCUS_NONE

	_update_eit_buttons()
