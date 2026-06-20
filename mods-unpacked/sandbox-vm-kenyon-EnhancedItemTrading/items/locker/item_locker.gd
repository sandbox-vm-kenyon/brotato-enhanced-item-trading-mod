extends ItemData

# Personal Weapon Locker — item given to each player at run start.
# Holds one weapon aside. Not tradeable, not discardable.
# When selected in inventory, shows "Get <WeaponName> from Locker" if applicable.

func _init():
	my_id = "item_locker_eit"
	name = "EIT_LOCKER_NAME"
	description = "EIT_LOCKER_DESC"

	# Locker has no stat effects — it's a UI container only.
	max_nb = 1
	can_be_sold = false
	# Prevent trading the locker itself between players.
	# (We tag it; coop_item_popup checks my_id == "item_locker_eit")

	# TODO: set icon path once art asset is provided
	# icon = preload("res://mods-unpacked/sandbox-vm-kenyon-EnhancedItemTrading/items/locker/item_locker.png")
