extends Control

# Reference to the main menu scene
@export var main_menu_path: String = "res://ui/main_menu.tscn"

func _ready():
	# Connect back button
	$SettingsContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	# Return to main menu
	get_tree().change_scene_to_file(main_menu_path)
