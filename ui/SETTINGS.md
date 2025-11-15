# Settings System

This document describes the settings system for ERROR 67, including how to use and integrate settings into your game.

## Files

- `settings_menu.tscn` - Settings menu scene with UI controls
- `settings_menu.gd` - Settings menu logic
- `settings_manager.gd` - Global settings manager (autoload singleton)

## Settings Available

### 1. HUD Size
- **Range**: 50% to 200%
- **Default**: 100%
- **Purpose**: Scales all HUD elements (health bar, ammo display, etc.) for accessibility
- **Increments**: 10%

### 2. Sound Volume
- **Range**: 0% to 100%
- **Default**: 100%
- **Purpose**: Adjusts master audio volume
- **Technical**: Converts to -80dB to 0dB range internally
- **Note**: 0% effectively mutes all audio

### 3. Difficulty
- **Options**: Easy, Normal, Hard
- **Default**: Normal
- **Purpose**: Adjusts game difficulty through multipliers
- **Multipliers**:
  - Easy: 0.75x (enemies deal 75% damage, have 75% health)
  - Normal: 1.0x (standard gameplay)
  - Hard: 1.5x (enemies deal 150% damage, have 150% health)

## Setup

### 1. Add Settings Manager as Autoload (Singleton)

To make settings accessible globally:

1. Open **Project → Project Settings**
2. Go to the **Autoload** tab
3. Click the folder icon and select `res://ui/settings_manager.gd`
4. Set the Node Name to: `SettingsManager`
5. Click **Add**
6. Click **Close**

Alternatively, add this to `project.godot`:
```
[autoload]

SettingsManager="*res://ui/settings_manager.gd"
```

### 2. Update Existing HUD Elements

The health bar and ammo display have been updated to use HUD scale settings. Any new HUD elements should follow this pattern.

## Usage in Your Code

### Accessing Settings

```gdscript
# Get current HUD scale
var hud_scale = SettingsManager.get_hud_scale()

# Get current difficulty
var difficulty = SettingsManager.get_difficulty()

# Get difficulty multiplier for game balance
var multiplier = SettingsManager.get_difficulty_multiplier()
```

### Listening to Settings Changes

```gdscript
func _ready():
    # Connect to signals
    SettingsManager.hud_scale_changed.connect(_on_hud_scale_changed)
    SettingsManager.difficulty_changed.connect(_on_difficulty_changed)

func _on_hud_scale_changed(new_scale: float):
    # Update your UI element scale
    my_ui_element.scale = Vector2(new_scale, new_scale)

func _on_difficulty_changed(new_difficulty: String):
    # Adjust gameplay based on difficulty
    match new_difficulty:
        "Easy":
            enemy_damage = base_damage * 0.75
        "Normal":
            enemy_damage = base_damage
        "Hard":
            enemy_damage = base_damage * 1.5
```

### Applying HUD Scale to New UI Elements

For any new HUD element (CanvasLayer):

```gdscript
extends CanvasLayer

@onready var container = $MyContainer

func _ready():
    # Apply initial scale
    _apply_hud_scale()
    
    # Listen for changes
    SettingsManager.hud_scale_changed.connect(_on_hud_scale_changed)

func _apply_hud_scale():
    var scale = SettingsManager.get_hud_scale()
    container.scale = Vector2(scale, scale)

func _on_hud_scale_changed(new_scale: float):
    container.scale = Vector2(new_scale, new_scale)
```

### Using Difficulty in Enemy Scripts

```gdscript
extends CharacterBody2D

@export var base_health: float = 100.0
@export var base_damage: float = 10.0

var actual_health: float
var actual_damage: float

func _ready():
    var multiplier = SettingsManager.get_difficulty_multiplier()
    actual_health = base_health * multiplier
    actual_damage = base_damage * multiplier
    
    # Listen for difficulty changes (optional)
    SettingsManager.difficulty_changed.connect(_on_difficulty_changed)

func _on_difficulty_changed(new_difficulty: String):
    # Optionally update existing enemies when difficulty changes
    var multiplier = SettingsManager.get_difficulty_multiplier()
    actual_health = base_health * multiplier
    actual_damage = base_damage * multiplier
```

## Settings Storage

Settings are automatically saved to a config file at:
- **Location**: `user://settings.cfg`
- **Platform-specific paths**:
  - Windows: `%APPDATA%/Godot/app_userdata/ERROR 67/settings.cfg`
  - macOS: `~/Library/Application Support/Godot/app_userdata/ERROR 67/settings.cfg`
  - Linux: `~/.local/share/godot/app_userdata/ERROR 67/settings.cfg`

### Config File Structure

```ini
[display]
hud_scale=1.0

[audio]
master_volume=0.0

[gameplay]
difficulty="Normal"
```

## Signals

The SettingsManager emits these signals when settings change:

- `hud_scale_changed(new_scale: float)` - When HUD scale changes
- `volume_changed(new_volume: float)` - When volume changes (in dB)
- `difficulty_changed(new_difficulty: String)` - When difficulty changes

## Navigation

- From Main Menu: Click **SETTINGS** button
- From Settings: Click **BACK** button to return to main menu

## Future Enhancements

Potential additions to the settings system:

### Display Settings
- Fullscreen toggle
- VSync on/off
- Resolution selection
- Brightness/gamma adjustment

### Audio Settings
- Separate sliders for Music, SFX, Voice
- Audio balance (left/right)

### Gameplay Settings
- Control sensitivity
- Auto-aim assist
- Subtitle options

### Accessibility
- Colorblind modes
- High contrast mode
- Screen reader support
- Remappable controls

## Troubleshooting

### Settings not persisting
- Check that `user://` directory has write permissions
- Verify SettingsManager is loaded as an autoload

### HUD not scaling
- Ensure SettingsManager is added as autoload before HUD elements load
- Check that HUD elements are connecting to the `hud_scale_changed` signal
- Verify the container node reference is correct in your script

### Audio not changing
- Verify the Master audio bus exists in your audio bus layout
- Check that AudioServer is accessible (it should be by default)

### Difficulty not affecting gameplay
- Ensure your enemy/game scripts are using `get_difficulty_multiplier()`
- Check that base values are being multiplied, not replaced