# Glitch System Documentation

## Overview
The glitch system has **two types** of glitches:

1. **Player Glitches** - Abilities YOU control (Press Q, E, F, etc.)
2. **World Glitches** - Random chaos that happens TO you (No control!)

Together, they create a unique roguelike experience where you use glitches as tools while the game itself breaks around you.

## 🎮 Controls (Player Glitches Only)

- **Q** - Blink (teleport towards mouse)
- **E** - Noclip (phase through walls)
- **F** - Duplication (duplicate bullets)
- **Z** - Time Desync (slow enemies)
- **X** - Buffer Overflow (360° bullet spray)
- **C** - More glitches...

**World Glitches** happen automatically - you have NO control over them! (16 total glitches)

## 📁 File Structure

```
glitches/
├── glitch.gd                      # Base player Glitch class
├── glitch_types.gd                # 7 player glitch implementations
├── glitch_controller.gd           # Player glitch controller (energy system)
├── world_glitch.gd                # Base world Glitch class
├── world_glitch_types.gd          # 16 world glitch implementations
├── world_glitch_manager.gd        # Triggers world glitches randomly
├── example_world_glitch_usage.gd  # Integration examples
├── README.md                      # This file (overview)
└── WORLD_GLITCHES_README.md       # Complete world glitch docs
```

## 🔧 System Overview

### Player Glitches (Controlled)
**YOU activate these with keyboard keys**

- **Energy System**: Costs energy, regenerates over time (10/sec)
- **Cooldown System**: Must wait between uses
- **Strategic**: Use when you need them most
- **7 Available Glitches**: Blink, Noclip, Duplication, Time Desync, etc.

### World Glitches (Uncontrolled)
**GAME triggers these randomly**

- **Random Timing**: Every 15-45 seconds
- **No Energy Cost**: They just happen!
- **Severity Levels**: Minor → Moderate → Severe
- **16 Different Glitches**: Screen tear, control inversion, enemy multiplication, misplaced doors, etc.
- **Floor-Based**: More dangerous glitches on later floors

See **WORLD_GLITCHES_README.md** for complete world glitch documentation!

## 🎯 Player Glitches (You Control These)

### 🌀 Blink
**Teleport towards cursor**
- **Key**: Q
- **Cooldown**: 3 seconds
- **Duration**: Instant
- **Energy Cost**: 15
- **Effect**: Teleport 200 units towards mouse cursor
- **Use Case**: Dodge attacks, gap closer, quick repositioning

### 👻 Noclip
**Phase through walls**
- **Key**: E
- **Cooldown**: 8 seconds
- **Duration**: 4 seconds
- **Energy Cost**: 30
- **Effect**: Walk through walls and obstacles, player becomes translucent
- **Use Case**: Escape tight situations, explore secret areas, avoid damage

### 🔄 Duplication
**Duplicate nearby bullets**
- **Key**: F
- **Cooldown**: 6 seconds
- **Duration**: Instant
- **Energy Cost**: 25
- **Effect**: Duplicates all bullets within 100 units, slightly randomized
- **Use Case**: Double your firepower, create bullet storms

### ⏱️ Time Desync
**Slow down enemies**
- **Cooldown**: 12 seconds
- **Duration**: 5 seconds
- **Energy Cost**: 40
- **Effect**: Enemies move at 30% speed, player moves 50% faster
- **Use Case**: Overwhelming enemies, dodge patterns, line up shots

### 💥 Buffer Overflow
**Fire bullets in all directions**
- **Cooldown**: 10 seconds
- **Duration**: Instant
- **Energy Cost**: 35
- **Effect**: Fires 12 bullets in a circle around player
- **Use Case**: Clear surrounding enemies, panic button

### 🔥 Memory Leak
**Leave a damaging trail**
- **Cooldown**: 15 seconds
- **Duration**: 6 seconds
- **Energy Cost**: 30
- **Effect**: Leaves red damaging zones that hurt enemies (5 damage each)
- **Use Case**: Kite enemies, area denial, passive damage

### 👥 Stack Overflow
**Create temporary clones**
- **Cooldown**: 20 seconds
- **Duration**: 8 seconds
- **Energy Cost**: 50
- **Effect**: Creates 3 orbiting clones around player
- **Use Case**: Confuse enemies, visual distraction, screen presence

## 🌍 World Glitches (Game Controls These)

World glitches happen **automatically** and randomly. You have NO control!

**16 World Glitches Available:**
- **Minor** (Severity 1): Screen Tear, Slow Motion, Color Corruption, Low Resolution
- **Moderate** (Severity 2): Fast Forward, Bullet Spray, Control Inversion, Enemy Speed Boost, Ammo Drain, Gravity Flip, Bullet Noclip, Misplaced Room Trigger
- **Severe** (Severity 3): Invisible Enemies, Random Teleport, Enemy Multiplication, Spawn Rain

**How They Work:**
- Trigger every 15-45 seconds
- Last for 5-15 seconds
- Up to 2 can be active at once
- Severity increases on higher floors

**See WORLD_GLITCHES_README.md for full details!**

## 🎨 Starter Setup

By default, players start with:
- **3 Player Glitches**: Blink, Noclip, Duplication
- **World Glitches**: Minor severity only (Floor 1)

## 💡 Usage Examples

### Basic Setup (Already integrated in player.gd)

```gdscript
# In player _ready() function:
glitch_controller = GlitchController.new()
add_child(glitch_controller)

# Add starter glitches
glitch_controller.available_glitches = GlitchTypes.get_basic_glitches()
```

### Adding All Glitches

```gdscript
# Give player access to all glitches
glitch_controller.available_glitches = GlitchTypes.get_all_glitches()
```

### Adding Specific Glitch

```gdscript
# Add a specific glitch
var time_desync = GlitchTypes.TimeDesyncGlitch.new()
glitch_controller.add_glitch(time_desync)
```

### Creating Custom Glitch

```gdscript
# Create a custom glitch
class InvincibilityGlitch extends Glitch:
    var original_collision_mask: int = 0
    
    func _init() -> void:
        glitch_name = "God Mode"
        description = "Become invincible"
        cooldown = 30.0
        duration = 3.0
        energy_cost = 60
        icon_color = Color.GOLD
    
    func activate(player: Node2D) -> bool:
        if not super.activate(player):
            return false
        
        # Store and disable damage collision
        if player is Area2D:
            original_collision_mask = player.collision_mask
            player.collision_mask = 0  # Don't collide with anything
            player.modulate = Color.GOLD
        
        print("GLITCH: God Mode activated!")
        return true
    
    func deactivate(player: Node2D) -> void:
        super.deactivate(player)
        
        # Restore collision
        if player is Area2D:
            player.collision_mask = original_collision_mask
            player.modulate = Color.WHITE
        
        print("GLITCH: God Mode ended")
```

## ⚡ Energy System

- **Max Energy**: 100
- **Regen Rate**: 10 per second
- **Mechanics**: 
  - Energy regenerates automatically
  - Each glitch costs energy to use
  - Cannot use glitch without sufficient energy
  - Energy shown in console (can add UI later)

## 🔄 Cooldown System

- Each glitch has independent cooldown
- Cooldown starts AFTER the effect ends (for duration-based glitches)
- Instant glitches start cooldown immediately
- Cooldown percent available via `glitch.get_cooldown_percent()`

## 🎯 Signals

The GlitchController emits signals for UI integration:

```gdscript
# In player.gd
glitch_controller.glitch_activated.connect(_on_glitch_activated)
glitch_controller.glitch_deactivated.connect(_on_glitch_deactivated)
glitch_controller.energy_changed.connect(_on_energy_changed)
glitch_controller.cooldown_updated.connect(_on_cooldown_updated)

func _on_glitch_activated(glitch: Glitch) -> void:
    print("Activated: ", glitch.glitch_name)
    # Update UI, play sound, show effect

func _on_glitch_deactivated(glitch: Glitch) -> void:
    print("Deactivated: ", glitch.glitch_name)
    # Update UI, cleanup effects

func _on_energy_changed(current: int, max_energy: int) -> void:
    print("Energy: ", current, "/", max_energy)
    # Update energy bar

func _on_cooldown_updated(glitch: Glitch, percent: float) -> void:
    # Update cooldown display (percent is 0.0 to 1.0)
    pass
```

## 🎮 Roguelike Integration Ideas

### Unlocking Glitches
```gdscript
# When player finds glitch pickup
func _on_glitch_pickup(glitch_type: String) -> void:
    match glitch_type:
        "time_desync":
            glitch_controller.add_glitch(GlitchTypes.TimeDesyncGlitch.new())
        "buffer_overflow":
            glitch_controller.add_glitch(GlitchTypes.BufferOverflowGlitch.new())
```

### Glitch Upgrades
```gdscript
# Reduce cooldown
var glitch = glitch_controller.get_glitch_by_name("Blink")
if glitch:
    glitch.cooldown *= 0.5  # 50% faster cooldown

# Increase duration
var noclip = glitch_controller.get_glitch_by_name("Noclip")
if noclip:
    noclip.duration += 2.0  # +2 seconds
```

### Energy Pickups
```gdscript
# Restore energy
glitch_controller.add_energy(50)

# Increase max energy
glitch_controller.max_energy += 20
glitch_controller.current_energy = glitch_controller.max_energy
```

### Limited Use Glitches
```gdscript
# Create one-time use glitch
var super_glitch = Glitch.new()
super_glitch.glitch_name = "Nuclear Option"
super_glitch.max_uses = 1  # Only use once per run
super_glitch.energy_cost = 100
```

## 🐛 Troubleshooting

**Glitches don't activate:**
- Check console for "on cooldown" or "not enough energy" messages
- Verify input actions (Q, E, F, Z, X, C) are set up in Project Settings
- Make sure glitches are added to `available_glitches` array

**Noclip doesn't work:**
- Ensure walls/obstacles are on collision layer 1
- Check that player has collision_mask property

**Duplication doesn't duplicate bullets:**
- Make sure bullets are in "bullets" group (should auto-add in bullet.gd)
- Check bullets are within 100 units of player

**Time Desync doesn't affect enemies:**
- Enemies must be in "enemies" group
- Enemies must have a `speed` property
- Add enemies to group: `enemy.add_to_group("enemies")`

**Buffer Overflow doesn't fire:**
- Ensure player has GunController child node
- Check that bullet_scene is loaded in GunController

## 🎨 Visual Feedback Ideas

### Screen Shake
```gdscript
# Add camera shake when glitch activates
func apply_screen_shake(amount: float) -> void:
    if camera:
        var tween = create_tween()
        for i in range(10):
            var offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
            tween.tween_property(camera, "offset", offset, 0.05)
        tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
```

### Screen Distortion
```gdscript
# Add chromatic aberration or screen warp shader
# Apply to CanvasLayer when glitch.screen_distortion is true
```

### Particle Effects
```gdscript
# Spawn particles at player position
func spawn_glitch_particles(color: Color) -> void:
    var particles = CPUParticles2D.new()
    particles.amount = 20
    particles.lifetime = 0.5
    particles.explosiveness = 1.0
    particles.color = color
    add_child(particles)
```

## 📊 Balance Suggestions

### Early Game (Floors 1-3)
- Blink, Noclip, Duplication
- High energy regen (15/sec)
- Short cooldowns

### Mid Game (Floors 4-6)
- Unlock Buffer Overflow, Memory Leak
- Normal energy regen (10/sec)
- Medium cooldowns

### Late Game (Floors 7+)
- Unlock Time Desync, Stack Overflow
- Lower energy regen (8/sec)
- Longer cooldowns but more powerful

## 🔮 Future Glitch Ideas

- **Lag Spike**: Freeze all enemies for 1 second
- **Corrupted Save**: Return to previous room with current items
- **Resolution Bug**: Shrink player hitbox
- **Clipping Error**: Fall through floor to next level
- **Frame Skip**: Dash forward ignoring collision
- **Desync Bullets**: Bullets pass through walls
- **Packet Loss**: Become invisible to enemies
- **Integer Overflow**: Health wraps around (risky!)
- **Race Condition**: Teleport randomly
- **Null Pointer**: Delete nearest enemy

## 🎯 Testing Checklist

### Player Glitches ✅
- [ ] All glitches activate with correct keys (Q, E, F, Z, X, C)
- [ ] Energy drains and regenerates properly
- [ ] Cooldowns work correctly
- [ ] Noclip makes player translucent and pass through walls
- [ ] Blink teleports player towards mouse
- [ ] Duplication creates copies of bullets
- [ ] Time Desync slows enemies
- [ ] Buffer Overflow fires in all directions
- [ ] Memory Leak leaves damaging trail
- [ ] Stack Overflow creates orbiting clones
- [ ] Console shows glitch activation messages
- [ ] Glitches deactivate after duration expires

### World Glitches ⚠️
- [ ] World glitches trigger automatically every 15-45 seconds
- [ ] Console shows "WORLD GLITCH ACTIVE: [name]"
- [ ] Glitches end after their duration
- [ ] Screen Tear causes visual distortion
- [ ] Slow Motion affects everything
- [ ] Control Inversion reverses controls
- [ ] Enemy Speed Boost makes enemies faster
- [ ] Random Teleport moves player randomly
- [ ] Multiple world glitches can be active at once
- [ ] Glitch intensity increases on higher floors

## 🎮 Quick Start

### For Player Glitches:
```gdscript
# Already integrated in player.gd!
# Just press Q, E, or F in-game
```

### For World Glitches:
```gdscript
# In your main game/level scene:
var world_glitch_manager: WorldGlitchManager

func _ready() -> void:
    world_glitch_manager = WorldGlitchManager.new()
    add_child(world_glitch_manager)
    
    world_glitch_manager.enabled = true
    world_glitch_manager.min_interval = 20.0
    world_glitch_manager.max_interval = 40.0
    
    world_glitch_manager.world_glitch_started.connect(func(glitch):
        print("⚠️ World Glitch: ", glitch.glitch_name)
    )
```

See `example_world_glitch_usage.gd` for complete integration examples!

## 💻 Example: Custom Player Glitch

```gdscript
# Add to glitch_types.gd
class ExplosionGlitch extends Glitch:
    var explosion_radius: float = 150.0
    var explosion_damage: int = 50
    
    func _init() -> void:
        glitch_name = "Explosion"
        description = "Create damaging explosion around player"
        cooldown = 8.0
        duration = 0.0  # Instant
        energy_cost = 35
        icon_color = Color.ORANGE
        screen_shake = 10.0
    
    func activate(player: Node2D) -> bool:
        if not super.activate(player):
            return false
        
        # Create explosion area
        var area := Area2D.new()
        area.collision_layer = 0
        area.collision_mask = 4  # Hit enemies
        
        var shape := CircleShape2D.new()
        shape.radius = explosion_radius
        var collision := CollisionShape2D.new()
        collision.shape = shape
        area.add_child(collision)
        
        # Visual effect
        var visual := ColorRect.new()
        visual.size = Vector2(explosion_radius * 2, explosion_radius * 2)
        visual.position = Vector2(-explosion_radius, -explosion_radius)
        visual.color = Color(1, 0.5, 0, 0.5)
        area.add_child(visual)
        
        get_tree().root.add_child(area)
        area.global_position = player.global_position
        
        # Damage all enemies in radius
        var enemies_hit := 0
        area.body_entered.connect(func(body):
            if body.has_method("take_damage"):
                body.take_damage(explosion_damage)
                enemies_hit += 1
        )
        
        # Trigger collision detection
        await get_tree().physics_frame
        
        print("GLITCH: Explosion! Hit ", enemies_hit, " enemies")
        
        # Remove explosion
        area.queue_free()
        
        is_active = false
        return true
```

---

## 📚 Documentation Files

- **README.md** (this file) - Overview of both systems
- **WORLD_GLITCHES_README.md** - Complete world glitch documentation
  - All 16 world glitches detailed
  - Integration guide
  - Balance recommendations
  - Custom glitch creation

---

## 🎮 Summary

Your roguelike now has **TWO glitch systems**:

1. **Player Glitches** - Your tools
   - 7 abilities you activate
   - Costs energy, has cooldowns
   - Press Q, E, F, Z, X, C
   - Strategic and controlled

2. **World Glitches** - The chaos
   - 16 random environmental effects
   - Happens automatically every 15-45s
   - No player control
   - Adapts to floor/difficulty

**Together they create unpredictable, glitchy roguelike gameplay!**

Press Q, E, or F to use player glitches. World glitches will start happening automatically! 🎮✨⚠️