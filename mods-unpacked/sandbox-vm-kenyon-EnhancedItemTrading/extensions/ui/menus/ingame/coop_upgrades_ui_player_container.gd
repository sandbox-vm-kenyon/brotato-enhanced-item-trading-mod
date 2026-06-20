extends CoopUpgradesUIPlayerContainer

# Enhanced Item Trading — coop_upgrades_ui_player_container.gd
# Same as original mod: adds Give-to-Player buttons in the between-wave upgrades screen.

signal item_trade_button_pressed_eit(item_data, to_player_index)

func _ready() -> void:
	var buttons_clone = _take_button.get_parent().duplicate()
	_take_button.get_parent().get_parent().add_child(buttons_clone)
	_take_button.get_parent().get_parent().move_child(buttons_clone, _take_button.get_parent().get_index() + 1)
	for child in buttons_clone.get_children():
		child.free()

	var player_count = RunData.get_player_count()
	for target_index in player_count:
		if target_index == player_index:
			continue
		var btn = _take_button.duplicate()
		btn.text = "EIT_GIVE_TO_PLAYER_%s" % str(target_index + 1)
		btn.name = "EIT_trade_p%s" % (target_index + 1)
		btn.disconnect("pressed", self, "_on_TakeButton_pressed")
		btn.connect("pressed", self, "_on_trade_button_pressed", [target_index])
		btn.set_script(preload("res://ui/menus/global/my_menu_button.gd"))
		btn.add_stylebox_override("normal", _take_button.get_stylebox("normal").duplicate())
		buttons_clone.add_child(btn)


func _on_trade_button_pressed(to_index: int) -> void:
	if _button_pressed:
		return
	_button_pressed = true
	_button_delay_timer.start()

	if not RunData.is_can_trade_item(_item_data, to_index):
		SoundManager.play(Utils.get_rand_element(Player.new().hurt_sounds), 0, 0.0, true)
		return

	if _things_to_process_container:
		_things_to_process_container.consumables.remove_element(_consumable_data)

	emit_signal("item_trade_button_pressed_eit", _item_data, to_index)
