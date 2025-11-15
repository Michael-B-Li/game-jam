# UI System Summary - ERROR 67

Complete overview of the UI system including main menu, settings, and HUD components.

## 📁 File Structure

```
ui/
├── main_menu.tscn              # Main menu scene
├── main_menu.gd                # Main menu script
├── settings_menu.tscn          # Settings screen scene
├── settings_menu.gd            # Settings screen script
├── settings_manager.gd         # Global settings autoload (singleton)
├── exclamation_mark.svg        # Pixelated red exclamation mark graphic
├── exclamation_mark.gd         # Animation script for exclamation marks
├── health_bar.tscn             # Player health display
├── health_bar.gd               # Health bar script (HUD scale aware)
├── ammo_display.tscn           # Ammo counter display
├── ammo_display.gd             # Ammo display script (HUD scale aware)
├── example_enemy_with_difficulty.gd  # Reference implementation
├── MAIN_MENU.md                # Main menu documentation
├── SETTINGS.md                 # Detailed settings documentation
├── QUICK_SETTINGS_REFERENCE.md # Quick reference guide
└── UI_SYSTEM_SUMMARY.md        # This file
```

## 🎮 Main Menu

### Features
- **ERROR 67** title in golden text with outline
- **3 Buttons**: Play, Settings, Quit
- **Animated exclamation marks**: 4 pixelated red marks that fade in/out
- **Dark theme**: Blue-gray background with styled buttons
- **Keyboard navigation**: Tab/arrows + Enter

### Navigation
- **Play** → Loads `res://player/gun_test.tscn`
- **Settings** → Loads `res://ui/settings_menu.tscn`
- **Quit** → Exits game via `get_tree().quit()`

## ⚙️ Settings Menu

### Three Main Settings

#### 1. HUD Size
- **Type**: Horizontal slider
- **Range**: 0.5 to 2.0 (50% to 200%)
- **Default**: 1.0 (100%)
- **Increments**: 0.1 (10%)
- **Affects**: All HUD elements (health bar, ammo display, etc.)

#### 2. Sound Volume
- **Type**: Horizontal slider
- **Range**: 0 to 100 (displayed as percentage)
- **Default**: 100%
- **Technical**: Converts to -80dB to 0dB for AudioServer
- **Affects**: Master audio bus

#### 3. Difficulty
- **Type**: Dropdown/OptionButton
- **Options**: Easy, Normal, Hard
- **Default**: Normal
- **Multipliers**:
  - Easy: 0.75x (enemies weaker)
  - Normal: 1.0x (standard)
  - Hard: 1.5x (enemies stronger)

### Settings Storage
- **File**: `user://settings.cfg`
- **Format**: INI-style ConfigFile
- **Persistence**: Auto-saves on every change
- **Platform paths**:
  - Windows: `%APPDATA%/Godot/app_userdata/ERROR 67/settings.cfg`
  - macOS: `~/Library/Application Support/Godot/app_userdata/ERROR 67/settings.cfg`
  - Linux: `~/.local/share/godot/app_userdata/ERROR 67/settings.cfg`

## 🔧 Settings Manager (Autoload)

### Setup
Add to `project.godot`:
```
[autoload]
SettingsManager="*res://ui/settings_manager.gd"
```

### API

#### Get Methods
```gdscript
SettingsManager.get_hud_scale() -> float          # 0.5 to 2.0
SettingsManager.get_volume() -> float             # -80 to 0 dB
SettingsManager.get_difficulty() -> String        # "Easy", "Normal", "Hard"
SettingsManager.get_difficulty_multiplier() -> float  # 0.75, 1.0, 1.5
```

#### Set Methods
```gdscript
SettingsManager.set_hud_scale(scale: float)
SettingsManager.set_volume(volume_db: float)
SettingsManager.set_difficulty(diff: String)
```

#### Signals
```gdscript
signal hud_scale_changed(new_scale: float)
signal volume_changed(new_volume: float)
signal difficulty_changed(new_difficulty: String)
```

## 📊 HUD Components

### Health Bar
- **Location**: Bottom-left corner
- **Shows**: Current/max health with progress bar
- **Color coding**:
  - >50%: Bright red
  - 25-50%: Orange-red
  - <25%: Dark red
- **HUD Scale**: Automatically applies scale from settings

### Ammo Display
- **Location**: Bottom-right corner
- **Shows**: Current / Max ammo with bullet icon
- **Color coding**:
  - >30%: White
  - ≤30%: Yellow
  - 0%: Red
- **HUD Scale**: Automatically applies scale from settings

## 💡 Implementation Examples

### Adding HUD Scale to New UI Element

```gdscript
extends CanvasLayer

@onready var container = $MyContainer

func _ready():
    # Apply initial scale
    var scale = SettingsManager.get_hud_scale()
    container.scale = Vector2(scale, scale)
    
    # Listen for changes
    SettingsManager.hud_scale_changed.connect(_on_hud_scale_changed)

func _on_hud_scale_changed(new_scale: float):
    container.scale = Vector2(new_scale, new_scale)
```

### Using Difficulty in Enemy

```gdscript
extends CharacterBody2D

@export var base_health: float = 100.0
@export var base_damage: float = 10.0

func _ready():
    var mult = SettingsManager.get_difficulty_multiplier()
    var health = base_health * mult
    var damage = base_damage * mult
```

## 🎨 Visual Design

### Color Palette
- **Background**: `Color(0.1, 0.1, 0.15, 1)` - Dark blue-gray
- **Title**: `Color(1, 0.9, 0.6, 1)` - Golden yellow
- **Button bg**: `Color(0.2, 0.3, 0.4, 1)` - Blue-gray
- **Button border**: `Color(0.8, 0.8, 0.8, 1)` - Light gray
- **Hover**: `Color(1, 0.9, 0.6, 1)` - Golden yellow
- **Exclamation**: `#ff0000` - Pure red

### Typography
- **Font**: Snowbell (`res://snowbell-font/Snowbell-Wp4g9.ttf`)
- **Title size**: 64px (main menu), 48px (settings)
- **Button size**: 32px
- **Label size**: 24-32px

### Layout
- **Centered**: All menus use centered VBoxContainer
- **Spacing**: 20-40px between elements
- **Button size**: 300x60px minimum
- **Rounded corners**: 8px radius

## 🎬 Animations

### Exclamation Marks
- **Count**: 4 (2 left, 2 right)
- **Animation**: Fade in/out loop
- **Timing**: Staggered (0.8-1.1s fade, 0.2-0.5s delay)
- **Effect**: Creates pulsing warning aesthetic
- **Pixelated**: Uses TEXTURE_FILTER_NEAREST

## 🚀 Quick Start

1. **Set main scene** to `res://ui/main_menu.tscn`
2. **Add autoload**: `SettingsManager` → `res://ui/settings_manager.gd`
3. **Run game**: Menu appears with animations
4. **Test settings**: Adjust HUD scale to see health/ammo resize
5. **Integrate difficulty**: Use multipliers in enemy scripts

## ✅ Features Checklist

- [x] Main menu with Play/Settings/Quit
- [x] Animated pixelated exclamation marks
- [x] Settings menu with 3 adjustable options
- [x] HUD scale adjustment (50%-200%)
- [x] Sound volume control (0%-100%)
- [x] Difficulty selection (Easy/Normal/Hard)
- [x] Settings persistence (saved to file)
- [x] Global SettingsManager singleton
- [x] HUD components respect scale setting
- [x] Keyboard navigation support
- [x] Example enemy script with difficulty
- [x] Comprehensive documentation

## 📚 Documentation Files

- **MAIN_MENU.md**: Main menu and settings menu overview
- **SETTINGS.md**: Detailed settings system documentation (224 lines)
- **QUICK_SETTINGS_REFERENCE.md**: Quick API reference
- **UI_SYSTEM_SUMMARY.md**: This file - complete overview

## 🔮 Future Enhancements

### Potential Additions
- Separate audio buses (Music, SFX, Voice)
- Fullscreen/windowed toggle
- VSync control
- Resolution options
- Control remapping
- Colorblind modes
- High contrast mode
- Pause menu with settings access
- Credits screen
- Level select menu

## 🐛 Troubleshooting

**Settings not saving?**
- Check file permissions for user:// directory
- Verify SettingsManager is in autoload

**HUD not scaling?**
- Ensure SettingsManager autoload is before HUD scenes
- Check container node reference is correct
- Verify signal connections

**Audio not changing?**
- Confirm Master audio bus exists
- Check AudioServer is accessible

**Difficulty not working?**
- Use `get_difficulty_multiplier()` not just difficulty name
- Multiply base values, don't replace them

## 📞 Integration Notes

- All settings accessible via `SettingsManager` singleton
- HUD elements automatically apply scale on ready
- Settings changes emit signals for live updates
- Difficulty affects new enemies (not retroactive by default)
- All UI uses Snowbell font for consistency
- Dark theme matches "ERROR 67" aesthetic