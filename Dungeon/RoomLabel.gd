extends Label

# This function will be called by the Dungeon.gd script
func update_text(room_number: int):
	text = "Room: %s" % room_number
