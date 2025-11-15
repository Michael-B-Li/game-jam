# Quick Settings Reference

Quick guide for accessing and using game settings in ERROR 67.

## Accessing Settings (One-Liners)

```gdscript
# Get HUD scale
var scale = SettingsManager.get_hud_scale()  # Returns 0.5 to 2.0

# Get difficulty
var diff = SettingsManager.get_difficulty()  # Returns "Easy", "Normal", or "Hard"

# Get difficulty multiplier
var mult = SettingsManager.get_difficulty_multiplier()  # Returns 0.75, 1.0, or 1.5

# Get volume (in dB)
var vol = SettingsManager.get_volume()  # Returns -80 to 0
```

## Applying HUD Scale to Your UI

```gdscript
extends CanvasLayer

@onready var my_container = $MyContainer

func _ready():
    # Apply scale
    var scale = SettingsManager.get_hud_scale()
    my_container.scale = Vector2(scale, scale)
    
    # Listen for changes
    SettingsManager.hud_scale_changed.connect(_on_scale_changed)

func _on_scale_changed(new_scale: float):
    my_container.scale = Vector2(new_scale, new_scale)
```

## Using Difficulty in Enemy Scripts

```gdscript
extends CharacterBody2D

@export var base_health: float = 100.0
@export var base_damage: float = 10.0

func _ready():
    var multiplier = SettingsManager.get_difficulty_multiplier()
    health = base_health * multiplier
    damage = base_damage * multiplier
```

## Settings Values

### HUD Scale
- **Easy**: 0.5 (50%)
- **Normal**: 1.0 (100%)
- **Hard**: 2.0 (200%)
- **Step**: 0.1 (10%)

### Volume
- **Min**: -80 dB (muted)
- **Max**: 0 dB (full)
- **Displayed as**: 0% to 100%

### Difficulty Multipliers
- **Easy**: 0.75x (easier)
- **Normal**: 1.0x (standard)
- **Hard**: 1.5x (harder)

## Signals

```gdscript
# Connect to these signals to react to changes
SettingsManager.hud_scale_changed.connect(func(scale): print("HUD scale: ", scale))
SettingsManager.volume_changed.connect(func(vol): print("Volume: ", vol, " dB"))
SettingsManager.difficulty_changed.connect(func(diff): print("Difficulty: ", diff))
```

## Common Use Cases

### Scale a health bar
```gdscript
$HealthBar.scale = Vector2.ONE * SettingsManager.get_hud_scale()
```

### Adjust enemy stats
```gdscript
enemy_health *= SettingsManager.get_difficulty_multiplier()
enemy_damage *= SettingsManager.get_difficulty_multiplier()
```

### Check current difficulty
```gdscript
match SettingsManager.get_difficulty():
    "Easy":
        spawn_fewer_enemies()
    "Normal":
        normal_spawning()
    "Hard":
        spawn_more_enemies()
```

## Settings File Location

Settings are saved to: `user://settings.cfg`

**Platform-specific:**
- Windows: `%APPDATA%/Godot/app_userdata/ERROR 67/settings.cfg`
- macOS: `~/Library/Application Support/Godot/app_userdata/ERROR 67/settings.cfg`
- Linux: `~/.local/share/godot/app_userdata/ERROR 67/settings.cfg`

## Troubleshooting

**Q: SettingsManager is null**
A: Make sure it's added as an autoload in Project Settings → Autoload

**Q: Settings not saving**
A: Check file write permissions for the user:// directory

**Q: HUD not scaling**
A: Ensure you're scaling the container node, not individual elements

**Q: Volume not working**
A: Verify the "Master" audio bus exists in your audio bus layout