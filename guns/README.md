# Gun System Documentation

## Overview
This gun system allows you to easily add different types of guns to your player with customizable properties like fire rate, damage, bullet spread, and more.

## Components

### 1. Gun Resource (`gun.gd`)
Base resource class that defines gun properties:
- `gun_name`: Display name of the gun
- `fire_rate`: Time between shots (seconds)
- `bullet_speed`: How fast bullets travel
- `damage`: Damage per bullet
- `bullet_count`: Number of bullets per shot (for shotgun-style spread)
- `spread_angle`: Angle of bullet spread (degrees)
- `ammo_capacity`: Max ammo (-1 for infinite)
- `reload_time`: Time to reload (seconds)
- `automatic`: Hold to shoot vs click per shot
- `bullet_color`: Visual color of bullets

### 2. Bullet (`bullet.gd` & `bullet.tscn`)
Projectile that moves and deals damage on collision.

### 3. GunController (`gun_controller.gd`)
Main controller that handles:
- Shooting mechanics
- Ammo management
- Reloading
- Gun switching
- Input handling

### 4. Gun Presets (`gun_presets.gd`)
Pre-configured guns ready to use:
- **Pistol**: Balanced semi-auto (12 rounds, 0.3s fire rate)
- **Shotgun**: 8 pellets with wide spread (6 rounds, 0.8s fire rate)
- **Machine Gun**: Full-auto with moderate spread (30 rounds, 0.1s fire rate)
- **Sniper**: High damage, no spread (5 rounds, 1.5s fire rate)
- **Burst Rifle**: 3-round burst (24 rounds, 0.5s fire rate)
- **Minigun**: Ultra-fast full-auto (100 rounds, 0.05s fire rate)

## Usage

### Basic Setup (Already in player.gd)

```gdscript
# In player _ready() function:
gun_controller = GunController.new()
add_child(gun_controller)

# Add all available guns
gun_controller.available_guns = GunPresets.get_all_guns()
gun_controller.current_gun = gun_controller.available_guns[0]

# Load bullet scene
gun_controller.bullet_scene = preload("res://bullet.tscn")
```

### Creating Custom Guns

```gdscript
# Method 1: Using Gun.new() with parameters
var custom_gun = Gun.new("Custom Gun", 0.2, 800.0, 15, 1, 0.0, false)

# Method 2: Create and set properties
var rocket_launcher = Gun.new()
rocket_launcher.gun_name = "Rocket Launcher"
rocket_launcher.fire_rate = 2.0
rocket_launcher.bullet_speed = 300.0
rocket_launcher.damage = 100
rocket_launcher.bullet_count = 1
rocket_launcher.spread_angle = 0.0
rocket_launcher.ammo_capacity = 4
rocket_launcher.reload_time = 3.0
rocket_launcher.automatic = false
rocket_launcher.bullet_color = Color.RED

# Add to available guns
gun_controller.add_gun(rocket_launcher)
```

### Adding Guns at Runtime

```gdscript
# Add a specific gun
gun_controller.add_gun(GunPresets.get_sniper())

# Switch to a gun by index
gun_controller.switch_gun(2)  # Switch to 3rd gun in array
```

## Controls

- **Shoot**: Left Mouse Button or Space
- **Reload**: R key
- **Switch Weapons**: Number keys 1-6
- **Movement**: WASD keys

## Signals

The GunController emits signals you can connect to for UI updates:

```gdscript
# In player.gd
gun_controller.gun_switched.connect(_on_gun_switched)
gun_controller.ammo_changed.connect(_on_ammo_changed)
gun_controller.reloading.connect(_on_reloading)

func _on_gun_switched(gun: Gun) -> void:
	print("Now using: ", gun.gun_name)
	# Update UI to show new gun

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	print("Ammo: ", current, "/", max_ammo)
	# Update ammo display

func _on_reloading(time: float) -> void:
	print("Reloading for ", time, " seconds")
	# Show reload animation/progress bar
```

## Collision Layers

The bullet scene uses:
- **Collision Layer**: 2 (bullets are on layer 2)
- **Collision Mask**: 4 (bullets detect layer 4)

Make sure your enemies are on **layer 4** for bullets to hit them.

## Enemy Damage System

For bullets to damage enemies, enemies need a `take_damage()` method:

```gdscript
# In enemy.gd
var health: int = 100

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took ", amount, " damage. Health: ", health)
	
	if health <= 0:
		die()

func die() -> void:
	queue_free()
```

## Customization Tips

### Making a Flamethrower
```gdscript
var flamethrower = Gun.new()
flamethrower.gun_name = "Flamethrower"
flamethrower.fire_rate = 0.05  # Very fast
flamethrower.bullet_speed = 200.0  # Slow bullets
flamethrower.damage = 2  # Low damage per hit
flamethrower.bullet_count = 3  # Multiple flames
flamethrower.spread_angle = 20.0  # Wide cone
flamethrower.ammo_capacity = 200
flamethrower.automatic = true
flamethrower.bullet_color = Color.ORANGE_RED
```

### Making a Laser Gun
```gdscript
var laser = Gun.new()
laser.gun_name = "Laser"
laser.fire_rate = 0.0  # Instant fire
laser.bullet_speed = 2000.0  # Very fast
laser.damage = 20
laser.spread_angle = 0.0  # Perfect accuracy
laser.ammo_capacity = -1  # Infinite ammo
laser.automatic = true
laser.bullet_color = Color.CYAN
```

### Making a Grenade Launcher
```gdscript
var grenade = Gun.new()
grenade.gun_name = "Grenade Launcher"
grenade.fire_rate = 1.0
grenade.bullet_speed = 300.0
grenade.damage = 50
grenade.ammo_capacity = 8
grenade.reload_time = 2.5
grenade.bullet_color = Color.DARK_GREEN
# Note: You'd need to create a custom grenade bullet that explodes
```

## Troubleshooting

**Bullets don't spawn:**
- Make sure `bullet_scene` is assigned in GunController
- Check that bullet.tscn exists at `res://bullet.tscn`

**Bullets don't hit enemies:**
- Verify enemy collision layers match bullet collision mask
- Ensure enemy has `take_damage(amount: int)` method

**Gun won't shoot:**
- Check if ammo is 0 (press R to reload)
- Verify input actions are set up in Project Settings

**Bullets go in wrong direction:**
- Bullets shoot toward mouse position
- Make sure GunController's global_position is correct

## Next Steps

1. Create visual muzzle flash effects
2. Add sound effects for shooting and reloading
3. Create a HUD to display current gun and ammo
4. Add gun pickup items in the game world
5. Implement weapon upgrade system
6. Add bullet trails or tracers for visual feedback
