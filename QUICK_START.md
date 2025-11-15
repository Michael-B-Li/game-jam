# Quick Start Guide - Gun & Glitch System Setup

## 📁 Folder Structure

All gun-related files are now organized in the `guns/` folder:

```
game-jam/
├── guns/                   # Gun system
│   ├── gun.gd              # Base Gun resource class
│   ├── gun_controller.gd   # Main shooting controller
│   ├── gun_presets.gd      # Pre-configured guns
│   ├── bullet.gd           # Bullet script
│   ├── bullet.tscn         # Bullet scene
│   ├── example_custom_gun.gd  # Example code
│   └── README.md           # Complete documentation
├── glitches/               # Glitch system ✨
│   ├── glitch.gd           # Base Glitch resource class
│   ├── glitch_types.gd     # All glitch implementations
│   ├── glitch_controller.gd # Glitch controller
│   └── README.md           # Complete documentation
├── player.gd               # Player script (includes both systems)
├── QUICK_START.md          # This file
└── TESTING.md              # Testing guide
```

## ✅ What's Already Done

Both the gun system AND glitch system are integrated into your player!

### New Files Created:

**Guns System:**
- `guns/` folder containing all gun system files:
  - `gun.gd` - Base gun resource class
  - `bullet.gd` - Bullet script with collision detection
  - `bullet.tscn` - Bullet scene file
  - `gun_controller.gd` - Main shooting controller
  - `gun_presets.gd` - 4 pre-made guns (Pistol, Rifle, Shotgun, Revolver)
  - `README.md` - Complete documentation

**Glitch System:**
- `glitches/` folder containing glitch system:
  - `glitch.gd` - Base glitch resource class
  - `glitch_types.gd` - 7 glitch implementations
  - `glitch_controller.gd` - Glitch controller with energy system
  - `README.md` - Complete documentation

### Updated Files:
- `player.gd` - Now includes gun controller AND glitch controller
- `project.godot` - Added shooting/reload/weapon switching + glitch controls

## 🎮 Controls

### Guns
- **Shoot**: Left Mouse Click or Spacebar
- **Reload**: R key
- **Switch Weapons**: 1-4 number keys

### Glitches ✨
- **Q** - Blink (teleport towards mouse)
- **E** - Noclip (phase through walls)
- **F** - Duplication (duplicate bullets)

### Movement
- **WASD** - Move around

## 🔫 Available Guns

1. **Pistol** - Balanced semi-auto (12 rounds, moderate damage)
2. **Rifle** - Fast semi-auto (30 rounds, higher damage)
3. **Revolver** - Powerful semi-auto (6 rounds, high damage)

## 🚀 Next Steps

### 1. Open in Godot Editor
Open the project in Godot 4.x

### 2. Verify Bullet Scene
The `guns/bullet.tscn` file has been created. If you get warnings about it:
- Open it in the editor (located in the `guns/` folder)
- It should have: Area2D → CollisionShape2D + ColorRect
- The ColorRect provides the visual (small white square)

### 3. Test the System
Run the game and:
- Move with WASD
- Click to shoot (bullets go toward mouse)
- Press R to reload
- Press 1-3 to switch weapons
- Press 3 for revolver (high damage, only 6 shots)

### 5. Set Up Enemy Collision (Important!)

For bullets to hit enemies AND glitches to work properly, add this to your enemy script:

```gdscript
# In enemy.gd
extends CharacterBody2D  # or RigidBody2D, etc.

var health: int = 100
var speed: float = 100.0  # Important for Time Desync glitch!

func _ready() -> void:
    add_to_group("enemies")  # Important for glitches!

func take_damage(amount: int) -> void:
    health -= amount
    print("Enemy took ", amount, " damage. Health: ", health)
    
    if health <= 0:
        die()

func die() -> void:
    queue_free()  # Remove enemy
```

Also ensure your enemy's collision layer is set to **layer 4** in the editor.

## 🎨 Customization

### Change Bullet Visuals
Edit `guns/bullet.tscn` in Godot:
- Select the ColorRect node
- Change size, color, or replace with a Sprite2D

### Add Muzzle Flash
```gdscript
# In gun_controller.gd shoot() function, add after spawning bullet:
var flash = muzzle_flash_scene.instantiate()
add_child(flash)
```

### Create Custom Guns
```gdscript
# Add to player.gd or any script
var laser_gun = Gun.new()
laser_gun.gun_name = "Laser"
laser_gun.fire_rate = 0.05
laser_gun.bullet_speed = 2000.0
laser_gun.damage = 15
laser_gun.automatic = true
laser_gun.bullet_color = Color.CYAN
laser_gun.ammo_capacity = -1  # Infinite ammo

gun_controller.add_gun(laser_gun)
```

### Add Gun Pickups
```gdscript
# In a pickup item script:
func _on_player_entered(player):
    player.gun_controller.add_gun(GunPresets.get_sniper())
    queue_free()
```

## 🐛 Troubleshooting

**"Bullets don't spawn"**
- Check console for warnings about guns/bullet.tscn
- Make sure `gun_controller.bullet_scene` is assigned

**"Bullets pass through enemies"**
- Enemy needs `take_damage(amount: int)` method
- Check enemy collision layer is 4
- Check bullet collision mask is 4

**"Can't shoot"**
- Ammo might be 0, press R to reload
- Check Input Map has "shoot" action

**"Weapons won't switch"**
- Check Input Map has "weapon_1" through "weapon_3"

## 📚 More Info

**Guns System**: See `guns/README.md` for:
- Complete gun API documentation
- Signal usage examples
- Advanced customization
- Creating special weapon types

**Glitch System**: See `glitches/README.md` for:
- All 7 available glitches (4 more to unlock!)
- Energy and cooldown systems
- Creating custom glitches
- Roguelike integration ideas
- Balance suggestions

## 🎯 Quick Test Checklist

### Guns ✅
- [ ] Game runs without errors
- [ ] Player appears on screen
- [ ] Player moves with WASD
- [ ] Clicking spawns bullets toward mouse
- [ ] Bullets appear on screen
- [ ] Pressing 1-4 switches weapons
- [ ] Console shows "Switched to: [Gun Name]"
- [ ] Pressing R reloads (console shows "Ammo: X/Y")
- [ ] Rifle (key 2) shoots automatically when held
- [ ] Shotgun (key 3) fires 8 pellets in a spread
- [ ] Revolver (key 4) has only 6 shots and high damage

### Glitches ✨
- [ ] Pressing Q teleports player towards mouse (Blink)
- [ ] Pressing E makes player translucent and walk through walls (Noclip)
- [ ] Pressing F duplicates nearby bullets (Duplication)
- [ ] Console shows "GLITCH ACTIVATED: [Glitch Name]"
- [ ] Console shows "Energy: X/100"
- [ ] Energy regenerates over time
- [ ] Can't use glitch when energy is too low

You're all set! Both gun and glitch systems are ready to use. 🎉🎮✨