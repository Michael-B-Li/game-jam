extends Control

# Reference to the main menu scene
@export var main_menu_path: String = "res://ui/main_menu.tscn"

# Settings values
var hud_scale: float = 1.0
var master_volume: float = 0.0  # In dB
var difficulty: String = "Normal"

# Audio bus indices
var master_bus_index: int = 0

func _ready():
	# Get audio bus index
	master_bus_index = AudioServer.get_bus_index("Master")

	# Load saved settings
	load_settings()

	# Connect UI elements
	$SettingsContainer/SettingsContent/HUDSizeContainer/HUDControlContainer/HUDSlider.value_changed.connect(_on_hud_slider_changed)
	$SettingsContainer/SettingsContent/SoundContainer/SoundControlContainer/SoundSlider.value_changed.connect(_on_sound_slider_changed)
	$SettingsContainer/SettingsContent/DifficultyContainer/DifficultyOptions.item_selected.connect(_on_difficulty_selected)
	$SettingsContainer/BackButton.pressed.connect(_on_back_pressed)

	# Initialize UI with current values
	update_ui()

func load_settings():
	# Load settings from config file
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	if err == OK:
		hud_scale = config.get_value("display", "hud_scale", 1.0)
		master_volume = config.get_value("audio", "master_volume", 0.0)
		difficulty = config.get_value("gameplay", "difficulty", "Normal")

	# Apply audio setting
	AudioServer.set_bus_volume_db(master_bus_index, master_volume)

	# Apply global settings
	if not Engine.has_meta("hud_scale"):
		Engine.set_meta("hud_scale", hud_scale)
	if not Engine.has_meta("difficulty"):
		Engine.set_meta("difficulty", difficulty)

func save_settings():
	# Save settings to config file
	var config = ConfigFile.new()

	config.set_value("display", "hud_scale", hud_scale)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("gameplay", "difficulty", difficulty)

	config.save("user://settings.cfg")

	# Update global settings
	Engine.set_meta("hud_scale", hud_scale)
	Engine.set_meta("difficulty", difficulty)

func update_ui():
	# Update HUD slider (0.5 to 2.0 range)
	$SettingsContainer/SettingsContent/HUDSizeContainer/HUDControlContainer/HUDSlider.value = hud_scale
	$SettingsContainer/SettingsContent/HUDSizeContainer/HUDControlContainer/HUDValueLabel.text = str(int(hud_scale * 100)) + "%"

	# Update sound slider (-40 to 0 dB range, but display as 0-100)
	var volume_percent = (master_volume + 40) / 40.0 * 100.0
	$SettingsContainer/SettingsContent/SoundContainer/SoundControlContainer/SoundSlider.value = volume_percent
	$SettingsContainer/SettingsContent/SoundContainer/SoundControlContainer/SoundValueLabel.text = str(int(volume_percent)) + "%"

	# Update difficulty dropdown
	var difficulty_options = $SettingsContainer/SettingsContent/DifficultyContainer/DifficultyOptions
	match difficulty:
		"Easy":
			difficulty_options.selected = 0
		"Normal":
			difficulty_options.selected = 1
		"Hard":
			difficulty_options.selected = 2

func _on_hud_slider_changed(value: float):
	hud_scale = value
	$SettingsContainer/SettingsContent/HUDSizeContainer/HUDControlContainer/HUDValueLabel.text = str(int(value * 100)) + "%"
	save_settings()

func _on_sound_slider_changed(value: float):
	# Convert 0-100 to -40 to 0 dB
	if value == 0:
		master_volume = -80  # Effectively muted
	else:
		master_volume = (value / 100.0 * 40.0) - 40.0

	AudioServer.set_bus_volume_db(master_bus_index, master_volume)
	$SettingsContainer/SettingsContent/SoundContainer/SoundControlContainer/SoundValueLabel.text = str(int(value)) + "%"
	save_settings()

func _on_difficulty_selected(index: int):
	match index:
		0:
			difficulty = "Easy"
		1:
			difficulty = "Normal"
		2:
			difficulty = "Hard"

	save_settings()

func _on_back_pressed():
	# Return to main menu
	get_tree().change_scene_to_file(main_menu_path)
