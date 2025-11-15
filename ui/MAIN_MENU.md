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
- **SETTINGS** - Opens the settings menu
- **QUIT** - Exits the game

The menu features animated pixelated red exclamation marks on both sides that fade in and out at different intervals, creating a dynamic warning aesthetic that fits the "ERROR 67" theme.

### Settings Menu
A placeholder settings menu with:
- Title display
- Placeholder content area for future settings
- **BACK** button to return to main menu

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

## Future Enhancements

The settings menu is currently a placeholder. You can add:
- Volume controls (master, music, SFX)
- Graphics settings
- Keybinding configuration
- Display mode (fullscreen/windowed)
- Accessibility options

## Integration Notes

- The Play button uses `get_tree().change_scene_to_file()` to transition to the game
- The Quit button calls `get_tree().quit()` to exit
- Signals are emitted (`play_pressed`, `settings_pressed`) for potential game state management
