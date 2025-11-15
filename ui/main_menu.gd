extends Control

# Signal emitted when play button is pressed
signal play_pressed
signal settings_pressed

# Reference to the game scene to load
@export var game_scene_path: String = "res://Dungeon/dungeonRoom.tscn"
@export var settings_scene_path: String = "res://ui/settings_menu.tscn"

func _ready():
	# Connect button signals
	$MenuContainer/ButtonContainer/PlayButton.pressed.connect(_on_play_pressed)
	$MenuContainer/ButtonContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$MenuContainer/ButtonContainer/QuitButton.pressed.connect(_on_quit_pressed)

	# Make sure the first button is focused for keyboard navigation
	$MenuContainer/ButtonContainer/PlayButton.grab_focus()

func _on_play_pressed():
	# Emit signal in case other systems need to know
	play_pressed.emit()

	# Load the game scene
	get_tree().change_scene_to_file(game_scene_path)

func _on_settings_pressed():
	# Emit signal in case other systems need to know
	settings_pressed.emit()

	# For now, print a message. Later this can load a settings scene
	print("Settings button pressed")

	# Optionally load settings scene if it exists
	if FileAccess.file_exists(settings_scene_path):
		get_tree().change_scene_to_file(settings_scene_path)
	else:
		# Create a simple popup if settings scene doesn't exist yet
		_show_settings_placeholder()

func _on_quit_pressed():
	# Quit the game
	get_tree().quit()

func _show_settings_placeholder():
	# Simple placeholder dialog for settings
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Settings menu coming soon!"
	dialog.title = "Settings"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())
