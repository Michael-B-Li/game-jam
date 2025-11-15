extends Node

# Global settings manager - autoload this as a singleton
# This allows any part of the game to access settings

# Settings values with defaults
var hud_scale: float = 1.0
var master_volume: float = 0.0  # In dB
var difficulty: String = "Normal"

# Audio bus index
var master_bus_index: int = 0

# Signals for when settings change
signal hud_scale_changed(new_scale: float)
signal volume_changed(new_volume: float)
signal difficulty_changed(new_difficulty: String)

func _ready():
	# Get audio bus index
	master_bus_index = AudioServer.get_bus_index("Master")

	# Load settings on startup
	load_settings()

func load_settings():
	"""Load settings from config file"""
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	if err == OK:
		hud_scale = config.get_value("display", "hud_scale", 1.0)
		master_volume = config.get_value("audio", "master_volume", 0.0)
		difficulty = config.get_value("gameplay", "difficulty", "Normal")
	else:
		# First time, use defaults
		hud_scale = 1.0
		master_volume = 0.0
		difficulty = "Normal"

	# Apply audio setting
	apply_audio_settings()

func save_settings():
	"""Save settings to config file"""
	var config = ConfigFile.new()

	config.set_value("display", "hud_scale", hud_scale)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("gameplay", "difficulty", difficulty)

	config.save("user://settings.cfg")

func set_hud_scale(scale: float):
	"""Set HUD scale and save"""
	hud_scale = clamp(scale, 0.5, 2.0)
	save_settings()
	hud_scale_changed.emit(hud_scale)

func set_volume(volume_db: float):
	"""Set master volume in dB and save"""
	master_volume = clamp(volume_db, -80.0, 0.0)
	apply_audio_settings()
	save_settings()
	volume_changed.emit(master_volume)

func set_difficulty(diff: String):
	"""Set difficulty and save"""
	if diff in ["Easy", "Normal", "Hard"]:
		difficulty = diff
		save_settings()
		difficulty_changed.emit(difficulty)

func apply_audio_settings():
	"""Apply current audio settings to the audio bus"""
	AudioServer.set_bus_volume_db(master_bus_index, master_volume)

func get_hud_scale() -> float:
	"""Get current HUD scale"""
	return hud_scale

func get_volume() -> float:
	"""Get current volume in dB"""
	return master_volume

func get_difficulty() -> String:
	"""Get current difficulty"""
	return difficulty

func get_difficulty_multiplier() -> float:
	"""Get a multiplier based on difficulty for game balance"""
	match difficulty:
		"Easy":
			return 0.75  # Enemies deal 75% damage, have 75% health, etc.
		"Normal":
			return 1.0   # Standard gameplay
		"Hard":
			return 1.5   # Enemies deal 150% damage, have 150% health, etc.
		_:
			return 1.0
