# UI System - Ammo Display

## 📁 Files

- `ammo_display.gd` - Script that handles ammo display logic
- `ammo_display.tscn` - UI scene with layout
- `README.md` - This file

## 🎨 Adding Snowbell Font

### Step 1: Download Snowbell Font

1. Go to: https://www.fontspace.com/snowbell-font-f148771
2. Click "Free Download"
3. Download the `Snowbell.ttf` file
4. **Alternative**: https://www.dafont.com/ and search "pixel font" for similar options

### Step 2: Import Font to Godot

1. Create a `fonts` folder in your project: `game-jam/fonts/`
2. Copy `Snowbell.ttf` (or your pixel font) into the `fonts` folder
3. Godot will automatically import it

### Step 3: Apply Font to Ammo Label

1. Open `ammo_display.tscn` in Godot Editor
2. Select the `AmmoLabel` node
3. In the Inspector, find **Theme Overrides → Fonts**
4. Click the dropdown next to "Font"
5. Choose "Load" and select `res://fonts/Snowbell.ttf`
6. Done! The ammo text now uses Snowbell font

### Alternative Pixel Fonts (Free)

If you can't find Snowbell, these work great too:

- **m5x7** - https://managore.itch.io/m5x7
- **Tiny5** - https://www.fontspace.com/tiny5-font-f97905
- **Pixel Operator** - https://www.dafont.com/pixel-operator.font
- **Press Start 2P** - https://fonts.google.com/specimen/Press+Start+2P

## 🖼️ Bullet Icon Options

### Option 1: Using Built-in Icon (Current)

The script creates a simple bullet icon using ColorRect nodes. This works out of the box!

### Option 2: Custom Pixel Art Icon

If you want a custom bullet sprite:

1. Download a bullet icon from:
   - https://opengameart.org/content/ammo-sprite
   - https://itch.io/game-assets/tag-bullet/tag-pixel-art
   - Create your own 16x16 or 24x24 pixel bullet

2. Save it as `bullet_icon.png` in `game-jam/Assets/`

3. In `ammo_display.tscn`:
   - Select the `BulletIcon` node
   - Change type to `TextureRect`
   - In Inspector, load your `bullet_icon.png` as the Texture

### Option 3: Use Godot's Built-in Icon

```gdscript
# In ammo_display.gd, replace create_bullet_icon() with:
func create_bullet_icon() -> void:
	if bullet_icon is TextureRect:
		# Use a built-in Godot icon
		bullet_icon.texture = get_theme_icon("FixedMaterial", "EditorIcons")
```

## 🎯 Using the Ammo Display

### Add to Your Game Scene

1. Open your main game scene (e.g., `player.tscn` or main level scene)
2. Click "Instantiate Child Scene" (chain link icon)
3. Select `ui/ammo_display.tscn`
4. Done! It will automatically find the player and connect

### Make Sure Player is in Group

The UI looks for a node in the "player" group:

```gdscript
# In your player.gd _ready() function:
add_to_group("player")
```

## 🎨 Customization

### Change Position

In `ammo_display.tscn`:
- Select `AmmoContainer`
- Adjust `offset_left`, `offset_top`, `offset_right`, `offset_bottom`
- Current: Bottom-right corner

### Change Colors

In `ammo_display.gd`, modify `update_ammo_display()`:

```gdscript
# Current colors:
# Empty (0 ammo) = RED
# Low (< 30%) = YELLOW
# Normal = WHITE

# Change to your preference:
if current == 0:
	ammo_label.modulate = Color.ORANGE_RED  # Custom color
```

### Change Font Size

In `ammo_display.tscn`:
- Select `AmmoLabel`
- Inspector → Theme Overrides → Font Sizes → Font Size
- Default: 32 (change to 24, 48, etc.)

### Add Outline/Shadow

In `ammo_display.tscn`, `AmmoLabel` Inspector:
- Theme Overrides → Colors → Font Outline Color (black)
- Theme Overrides → Constants → Outline Size (4 pixels)

Already applied for visibility!

## 🔧 Troubleshooting

**Ammo doesn't show:**
- Make sure player has `add_to_group("player")` in _ready()
- Check that player has gun_controller
- Look at console for errors

**Font looks blurry:**
- In font import settings, disable "MSDF"
- Enable "Force Autohinter"
- Set "Antialiasing" to "None" for crisp pixels

**Icon doesn't show:**
- Check that `BulletIcon` node exists
- Make sure `create_bullet_icon()` is being called
- Verify node type is correct (Control or TextureRect)

## 📊 Current Features

✅ Shows current ammo / max ammo
✅ Changes color based on ammo level (red = empty, yellow = low)
✅ Updates automatically when shooting/reloading
✅ Updates when switching guns
✅ Shows "∞" for infinite ammo guns
✅ Pixel art bullet icon
✅ Positioned in bottom-right corner
✅ Black outline for visibility

## 🚀 Future Enhancements

Ideas for expanding the UI:

- Gun name display
- Reload progress bar
- Gun icon/sprite
- Ammo reserve count (total ammo across all guns)
- Gun switching indicator
- Energy bar for glitches
- Health bar
- Score/combo counter

---

**The ammo display is ready to use!** Just add Snowbell font and instantiate the scene. 🎮✨
