extends UpgradesUI

# Enhanced Item Trading — upgrades_ui.gd
# Connects between-wave trade signals to consumable dispatch.

func _ready() -> void:
	if not RunData.is_coop_run:
		return
	if RunData.is_coop_run != is_coop_ui:
		return

	for player_index in RunData.get_player_count():
		var container = _get_player_container(player_index)
		container.connect("item_trade_button_pressed_eit", self, "_on_item_trade_button_pressed_eit", [player_index])


func _on_item_trade_button_pressed_eit(item_data: ItemParentData, to_player_index: int, from_player_index: int) -> void:
	_player_is_choosing[from_player_index] = false
	var consumable = _showing_option[from_player_index]
	consumable.player_index = to_player_index
	emit_signal("item_take_button_pressed", item_data, consumable)

	LinkedStats.reset_player(from_player_index)
	_update_player_stats(from_player_index)

	if not _extra_items_to_process[from_player_index]:
		emit_signal("consumable_selected", consumable)
		_showing_option[from_player_index] = null
	if not _show_next_player_options():
		emit_signal("options_processed")
