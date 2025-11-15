# Gun System Testing Guide

## Quick Test (30 seconds)

### 1. Open in Godot
- Launch Godot 4.x
- Open this project

### 2. Run the Game
- Press **F5** or click the Play button ▶️
- The player (blue rectangle) should appear in the center

### 3. Test Shooting
- **Move mouse** - aim direction
- **Left Click** or **Space** - shoot bullets toward mouse
- Bullets should appear as small colored squares

### 4. Test Weapon Switching
- Press **1** - Pistol (yellow bullets)
- Press **2** - Rifle (orange bullets)
- Press **3** - Revolver (silver/white bullets)

### 5. Test Reloading
- Keep shooting until ammo runs out
- Press **R** - reload
- Check console for "Ammo: X/Y" messages

## What You Should See

✅ **Console Output:**
```
Switched to: Pistol
Ammo: 11/12
Ammo: 10/12
...
Ammo: 0/12
Ammo: 12/12  (after reload)
```

✅ **Visual:**
- Player moves with WASD
- Bullets spawn at player position
- Bullets fly toward mouse cursor
- Different colored bullets per gun
- Bullets disappear after 5 seconds or off-screen

## Gun Stats Reference

| Gun      | Key | Ammo | Damage | Fire Rate | Color  |
|----------|-----|------|--------|-----------|--------|
| Pistol   | 1   | 12   | 10     | 0.3s      | Yellow |
| Rifle    | 2   | 30   | 15     | 0.15s     | Orange |
| Revolver | 3   | 6    | 25     | 0.5s      | Silver |

## Troubleshooting

### Bullets don't appear
- Check Output tab in Godot for errors
- Make sure `guns/bullet.tscn` exists in the guns folder
- Verify Console shows "Switched to: [gun name]"

### Player doesn't move
- Check Input Map has WASD keys assigned
- Look for errors in Output tab

### No weapon switching
- Press number keys 1, 2, 3 (not numpad)
- Check console for "Switched to:" messages

### Can't shoot
- If ammo is 0, press R to reload
- Check if "shoot" action exists in Input Map
- Try both Left Click and Space

## Testing With Enemies

To test damage, add this to your enemy script:

```gdscript
var health: int = 50

func take_damage(amount: int) -> void:
    health -= amount
    print("Enemy hit! Health: ", health)
    if health <= 0:
        queue_free()
```

Make sure enemy is on **collision layer 4** so bullets hit it.

## Full Controls

- **W** - Move up
- **A** - Move left  
- **S** - Move down
- **D** - Move right
- **Mouse** - Aim
- **Left Click / Space** - Shoot
- **R** - Reload
- **1, 2, 3** - Switch weapons

## Success Checklist

- [ ] Player appears on screen
- [ ] Player moves with WASD
- [ ] Bullets spawn when clicking
- [ ] Bullets move toward mouse
- [ ] Can switch between 3 guns
- [ ] Console shows gun switches
- [ ] Console shows ammo changes
- [ ] Reloading works (R key)
- [ ] Revolver only has 6 shots
- [ ] Rifle shoots faster than others

If all checks pass, the gun system is working! 🎉