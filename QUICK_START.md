# Quick Start Guide - Gun System Setup

## ✅ What's Already Done

The gun system is now integrated into your player! Here's what's been added:

### New Files Created:
- `gun.gd` - Base gun resource class
- `bullet.gd` - Bullet script with collision detection
- `bullet.tscn` - Bullet scene file
- `gun_controller.gd` - Main shooting controller
- `gun_presets.gd` - Pre-made gun configurations
- `GUN_SYSTEM_README.md` - Complete documentation

### Updated Files:
- `player.gd` - Now includes gun controller
- `project.godot` - Added shooting/reload/weapon switching controls

## 🎮 Controls

- **Shoot**: Left Mouse Click or Spacebar
- **Reload**: R key
- **Switch Weapons**: 1-3 number keys
- **Movement**: WASD (already set up)

## 🔫 Available Guns

1. **Pistol** - Balanced semi-auto (12 rounds, moderate damage)
2. **Rifle** - Fast semi-auto (30 rounds, higher damage)
3. **Revolver** - Powerful semi-auto (6 rounds, high damage)

## 🚀 Next Steps

### 1. Open in Godot Editor
Open the project in Godot 4.x

### 2. Verify Bullet Scene
The `bullet.tscn` file has been created. If you get warnings about it:
- Open it in the editor
- It should have: Area2D → CollisionShape2D + ColorRect
- The ColorRect provides the visual (small white square)

### 3. Test the System
Run the game and:
- Move with WASD
- Click to shoot (bullets go toward mouse)
- Press R to reload
- Press 1-3 to switch weapons
- Press 3 for revolver (high damage, only 6 shots)

### 4. Set Up Enemy Collision (Important!)

For bullets to hit enemies, add this to your enemy script:

```gdscript
# In enemy.gd
var health: int = 100

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
Edit `bullet.tscn` in Godot:
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
- Check console for warnings about bullet.tscn
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

See `GUN_SYSTEM_README.md` for:
- Complete API documentation
- Signal usage examples
- Advanced customization
- Creating special weapon types

## 🎯 Quick Test Checklist

- [ ] Game runs without errors
- [ ] Player moves with WASD
- [ ] Clicking spawns bullets toward mouse
- [ ] Bullets appear on screen
- [ ] Pressing 1-3 switches weapons
- [ ] Console shows "Switched to: [Gun Name]"
- [ ] Pressing R reloads (console shows "Ammo: X/Y")
- [ ] Revolver (key 3) has only 6 shots and high damage

You're all set! The gun system is ready to use. 🎉