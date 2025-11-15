# Main Menu

This directory contains the main menu implementation for the game.

## Files

- `main_menu.tscn` - The main menu scene
- `main_menu.gd` - Main menu logic and button handlers
- `settings_menu.tscn` - Settings menu scene
- `settings_menu.gd` - Settings menu logic
- `exclamation_mark.svg` - Pixelated red exclamation mark graphic
- `exclamation_mark.gd` - Animation script for exclamation marks

## Features

### Main Menu
The main menu provides three options:
- **PLAY** - Starts the game (loads `gun_test.tscn`)
- **SETTINGS** - Opens the settings menu with options for:
  - HUD Size (50%-200%)
  - Sound Volume (0%-100%)
  - Difficulty (Easy/Normal/Hard)
- **QUIT** - Exits the game

The menu features animated pixelated red exclamation marks on both sides that fade in and out at different intervals, creating a dynamic warning aesthetic that fits the "ERROR 67" theme.

### Settings Menu
A fully functional settings menu with:
- **HUD Size** slider - Adjust UI scale from 50% to 200%
- **Sound Volume** slider - Control master audio from 0% to 100%
- **Difficulty** dropdown - Choose Easy, Normal, or Hard
- **BACK** button to return to main menu
- Settings are automatically saved to `user://settings.cfg`

## Setup

### Setting as Main Scene

To make the main menu your starting scene:

1. Open the Godot editor
2. Go to **Project → Project Settings**
3. Under **Application → Run**, set **Main Scene** to `res://ui/main_menu.tscn`
4. Click **Close**

Alternatively, you can edit `project.godot` and change:
```
run/main_scene="res://player/gun_test.tscn"
```
to:
```
run/main_scene="res://ui/main_menu.tscn"
```

### Customization

#### Changing the Game Scene
Edit `main_menu.gd` and modify the `game_scene_path` variable:
```gdscript
@export var game_scene_path: String = "res://your/game/scene.tscn"
```

#### Changing the Title
Edit `main_menu.tscn` in the Godot editor or modify the TitleLabel text property.

#### Styling
The menu uses the Snowbell font from `res://snowbell-font/Snowbell-Wp4g9.ttf`.
Button styles are defined using StyleBoxFlat with:
- Background color: `Color(0.2, 0.3, 0.4, 1)`
- Border color: `Color(0.8, 0.8, 0.8, 1)`
- Rounded corners with 8px radius

#### Customizing Exclamation Mark Animations
Edit `exclamation_mark.gd` to adjust animation parameters:
```gdscript
@export var fade_duration: float = 1.0  # How long fade in/out takes
@export var fade_delay: float = 0.5     # How long to stay visible/invisible
```

Each exclamation mark in the scene has slightly different timing to create a staggered effect.

## Keyboard Navigation

The main menu supports keyboard navigation:
- **Tab/Arrow Keys** - Navigate between buttons
- **Enter/Space** - Activate selected button
- **ESC** - Can be used to quit (if you add the functionality)

## Settings System

For detailed information about the settings system, see `SETTINGS.md`.

The settings are stored in `user://settings.cfg` and persist between game sessions. The `SettingsManager` autoload singleton makes settings accessible from anywhere in the game.

## Future Enhancements

Potential additions to the settings menu:
- Separate volume controls (music, SFX, voice)
- Graphics settings (fullscreen, VSync, resolution)
- Keybinding configuration
- Display mode options
- Additional accessibility options

## Integration Notes

- The Play button uses `get_tree().change_scene_to_file()` to transition to the game
- The Quit button calls `get_tree().quit()` to exit
- Signals are emitted (`play_pressed`, `settings_pressed`) for potential game state management
