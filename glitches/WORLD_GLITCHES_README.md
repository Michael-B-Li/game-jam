# World Glitches Documentation

## Overview
World glitches are **uncontrollable environmental effects** that happen randomly during gameplay. Unlike player-activated glitches (Q, E, F), these glitches are triggered by the game itself, adding chaos and unpredictability to the roguelike experience.

Think of them as "the game breaking itself" - you have no control over when they happen or what they do. You just have to adapt and survive!

## 🎮 Key Differences

| Feature | Player Glitches | World Glitches |
|---------|----------------|----------------|
| **Control** | Player activates with keys | Happens automatically |
| **Timing** | On-demand (with cooldown) | Random intervals |
| **Energy Cost** | Costs energy | Free (but unwanted!) |
| **Effect** | Usually helpful | Can be helpful OR harmful |
| **Duration** | Fixed or instant | Timed, then ends |

## 📁 File Structure

```
glitches/
├── world_glitch.gd               # Base WorldGlitch class
├── world_glitch_types.gd         # All 16 world glitch implementations
├── world_glitch_manager.gd       # System that triggers glitches randomly
├── example_world_glitch_usage.gd # Integration example
└── WORLD_GLITCHES_README.md      # This file
```

## 🎯 How It Works

1. **WorldGlitchManager** runs in the background
2. Every 15-45 seconds (configurable), it triggers a random glitch
3. Glitch is selected based on:
   - Current floor level
   - Spawn weight (probability)
   - Current game conditions
4. Glitch runs for its duration, then ends automatically
5. Up to 2 glitches can be active at once

## 🔧 Severity Levels

Glitches are categorized by impact:

### **Severity 1 - Minor** (Blue)
Visual or slight gameplay changes, mostly harmless
- Screen Shake
- Screen Tear
- Low Resolution
- Color Corruption
- Slow Motion

### **Severity 2 - Moderate** (Yellow)
Noticeable gameplay impact, requires adaptation
- Fast Forward
- Bullet Spray
- Control Inversion
- Enemy Speed Boost
- Ammo Drain
- Gravity Flip

### **Severity 3 - Severe** (Orange)
Significant challenge, dangerous situations
- Invisible Enemies
- Random Teleport
- Enemy Multiplication
- Spawn Rain

### **Severity 4 - Critical** (Red)
Extreme situations, game-changing effects
- (Reserved for future ultra-rare glitches)

## 🌟 All 16 World Glitches

### 1. Screen Tear
**Severity:** Minor | **Duration:** 6s | **Weight:** 20
- Visual split/offset effect
- Screen appears to "tear" horizontally
- Disorienting but harmless

### 2. Slow Motion
**Severity:** Minor | **Duration:** 7s | **Weight:** 18
- Everything moves at 50% speed
- Affects player, enemies, bullets equally
- Can be strategic advantage

### 3. Fast Forward
**Severity:** Moderate | **Duration:** 6s | **Weight:** 12
- Everything moves at 200% speed
- Game becomes frantic and hectic
- Requires quick reactions

### 4. Color Corruption
**Severity:** Minor | **Duration:** 12s | **Weight:** 18
- Colors shift and change randomly
- Creates psychedelic effect
- No gameplay impact

### 5. Low Resolution
**Severity:** Minor | **Duration:** 15s | **Weight:** 20
- Graphics become heavily pixelated
- Retro aesthetic
- Purely visual

### 6. Bullet Spray
**Severity:** Moderate | **Duration:** 10s | **Weight:** 15
- Player bullets scatter wildly
- Spread increased by 5x
- Makes aiming difficult
- Requires closer combat

### 7. Control Inversion
**Severity:** Moderate | **Duration:** 8s | **Weight:** 15
- Movement controls reversed
- Up becomes down, left becomes right
- Extremely disorienting
- Player must adapt quickly

### 8. Enemy Speed Boost
**Severity:** Moderate | **Duration:** 10s | **Weight:** 15
- All enemies move 50% faster
- More aggressive pursuit
- Requires defensive play

### 9. Ammo Drain
**Severity:** Moderate | **Duration:** 12s | **Weight:** 12
- Ammo slowly decreases (1 per second)
- Forces reload management
- Can leave you empty at bad times

### 10. Invisible Enemies
**Severity:** Severe | **Duration:** 10s | **Weight:** 10
- Enemies become 85% transparent
- Still visible but very hard to see
- Must track by movement/sound
- Only spawns when enemies present

### 11. Random Teleport
**Severity:** Severe | **Duration:** 10s | **Weight:** 8
- Player teleports every 2 seconds
- Completely random position
- Can teleport into/out of danger
- Extremely chaotic

### 12. Enemy Multiplication
**Severity:** Severe | **Duration:** 10s | **Weight:** 8
- Enemies duplicate periodically
- 30% of enemies duplicate every 2s
- Can create overwhelming hordes
- Only spawns when enemies present

### 13. Spawn Rain
**Severity:** Severe | **Duration:** 8s | **Weight:** 10
- Objects fall from sky
- Random colored blocks
- Create obstacles and chaos
- Physics-based mayhem

### 14. Gravity Flip
**Severity:** Moderate | **Duration:** 8s | **Weight:** 15
- Gravity changes to random direction
- Can be up, down, left, or right
- Affects physics objects
- Disorienting movement

### 15. Bullet Noclip
**Severity:** Moderate | **Duration:** 12s | **Weight:** 12
- Bullets phase through walls
- Can hit enemies behind cover
- Changes combat strategy
- Allows for creative shots

### 16. Misplaced Room Trigger
**Severity:** Moderate | **Duration:** 20s | **Weight:** 10
- Door to next level spawns randomly
- Appears in unexpected location
- Glowing green/cyan portal
- Can advance level early if found
- Disappears after duration ends

## 🎲 Spawn System

### Weight-Based Selection
Each glitch has a "spawn weight" - higher = more likely:
```
Screen Tear (20)  - Very common
Slow Motion (18)  - Common
Control Inversion (15) - Moderate
Misplaced Room Trigger (10) - Moderate
Enemy Multiplication (8) - Rare
```

### Floor-Based Progression
As you progress, more dangerous glitches unlock:

**Floor 1-2:** Only Minor glitches (Severity 1)
**Floor 3-5:** Minor + Moderate glitches (Severity 1-2)
**Floor 6+:** All glitches including Severe (Severity 1-3)

### Conditional Spawning
Some glitches only spawn under certain conditions:
- **Invisible Enemies**: Requires enemies present
- **Enemy Multiplication**: Requires enemies present
- **Bullet Spray**: Requires player shooting
- **Ammo Drain**: Requires player has ammo

## 💻 Integration Guide

### Basic Setup

```gdscript
# In your main game scene or level manager
extends Node2D

var world_glitch_manager: WorldGlitchManager

func _ready() -> void:
    # Create manager
    world_glitch_manager = WorldGlitchManager.new()
    add_child(world_glitch_manager)
    
    # Configure
    world_glitch_manager.enabled = true
    world_glitch_manager.min_interval = 20.0  # Min 20s between glitches
    world_glitch_manager.max_interval = 40.0  # Max 40s between glitches
    world_glitch_manager.max_active_glitches = 2
    world_glitch_manager.glitch_intensity = 1  # Start with minor only
    world_glitch_manager.current_floor = 1
    
    # Connect signals
    world_glitch_manager.world_glitch_started.connect(_on_glitch_started)
    world_glitch_manager.world_glitch_ended.connect(_on_glitch_ended)

func _on_glitch_started(glitch: WorldGlitch) -> void:
    print("⚠️ ", glitch.glitch_name, " is now active!")
    # Show warning to player
    # Play sound effect
    # Update UI

func _on_glitch_ended(glitch: WorldGlitch) -> void:
    print("✅ ", glitch.glitch_name, " has ended")
    # Clear effects
```

### Advancing Floors

```gdscript
func advance_to_next_floor() -> void:
    var next_floor = world_glitch_manager.current_floor + 1
    world_glitch_manager.set_floor(next_floor)
    # Intensity automatically increases every 3 floors
```

### Checking Active Glitches

```gdscript
# Check if specific glitch is active
if world_glitch_manager.is_glitch_active("Control Inversion"):
    # Apply control inversion to player
    invert_controls = true

# Get all active glitch info
var active_info = world_glitch_manager.get_active_glitch_info()
for info in active_info:
    print(info["name"], " - ", info["time_remaining"], "s left")
```

### Testing Specific Glitches

```gdscript
# Force trigger for testing
world_glitch_manager.force_trigger_glitch("Random Teleport")

# Test all glitches
func test_all_glitches() -> void:
    var glitches = WorldGlitchTypes.get_all_world_glitches()
    for glitch in glitches:
        world_glitch_manager.start_glitch(glitch)
        await get_tree().create_timer(glitch.duration + 1.0).timeout
```

### Adjusting Difficulty

```gdscript
# Make glitches less frequent (easier)
world_glitch_manager.make_less_frequent()

# Make glitches more frequent (harder)
world_glitch_manager.make_more_frequent()

# Disable temporarily (boss fight, cutscene)
world_glitch_manager.set_enabled(false)
await get_tree().create_timer(30.0).timeout
world_glitch_manager.set_enabled(true)

# Clear all active glitches
world_glitch_manager.clear_all_glitches()
```

## 🎨 Visual Feedback

Each glitch has a `visual_effect` property that suggests how to display it:

```gdscript
func _on_glitch_started(glitch: WorldGlitch) -> void:
    match glitch.visual_effect:
        "screen_shake":
            apply_camera_shake()
        "distortion":
            apply_distortion_shader()
        "screen_tear":
            apply_tear_effect()
        "pixelate":
            apply_pixelation_shader()
        "color_shift":
            apply_color_shift_shader()
        "blur":
            apply_motion_blur()
```

## 🔊 Sound Design Ideas

**Minor Glitches:**
- Subtle "glitch" sound effects
- Electronic buzz
- Brief static

**Moderate Glitches:**
- Distorted alarm
- Warning beep
- Louder static burst

**Severe Glitches:**
- Loud error sound
- Klaxon alarm
- Screen "breaking" sound
- Intense electronic noise

## 🎯 Gameplay Integration Tips

### Control Inversion
```gdscript
# In player movement code
func _process(delta: float) -> void:
    var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # Check if controls inverted
    if world_glitch_manager.is_glitch_active("Control Inversion"):
        input = -input  # Reverse direction
    
    velocity = input * speed
```

### Bullet Spray
```gdscript
# In gun controller shoot function
var spread = current_gun.spread_angle

# Check if bullet spray active
if world_glitch_manager.is_glitch_active("Bullet Spray"):
    spread *= 5.0  # 5x spread multiplier

var spread_direction = shoot_direction.rotated(deg_to_rad(randf_range(-spread/2, spread/2)))
```

### Ammo Drain
The glitch handles this automatically, but you can add visual feedback:
```gdscript
func _on_glitch_started(glitch: WorldGlitch) -> void:
    if glitch.glitch_name == "Ammo Drain":
        show_ammo_drain_warning()
        ammo_display.modulate = Color.RED
```

## 🎲 Creating Custom World Glitches

```gdscript
# Add to world_glitch_types.gd
class MyCustomGlitch extends WorldGlitch:
    func _init() -> void:
        glitch_name = "Custom Glitch"
        description = "Does something weird"
        duration = 10.0
        severity = 2
        spawn_weight = 15
        min_floor = 1
        visual_effect = "screen_shake"
    
    func activate(world: Node2D) -> void:
        super.activate(world)
        # Your glitch logic here
        print("Custom glitch activated!")
    
    func process(world: Node2D, delta: float) -> void:
        super.process(world, delta)
        # Called every frame while active
    
    func deactivate(world: Node2D) -> void:
        # Cleanup
        super.deactivate(world)
```

## ⚖️ Balance Recommendations

### Early Game (Floors 1-3)
- Intensity: 1 (Minor only)
- Interval: 30-60 seconds
- Max Active: 1
- Goal: Introduce mechanics gently

### Mid Game (Floors 4-6)
- Intensity: 2 (Minor + Moderate)
- Interval: 20-40 seconds
- Max Active: 2
- Goal: Increase challenge

### Late Game (Floor 7+)
- Intensity: 3 (All glitches)
- Interval: 15-30 seconds
- Max Active: 2
- Goal: Maximum chaos

### Expert Mode
- Intensity: 3
- Interval: 10-20 seconds
- Max Active: 3
- Goal: Absolute mayhem

## 🐛 Troubleshooting

**Glitches don't trigger:**
- Make sure WorldGlitchManager is added to scene tree
- Check `enabled = true`
- Verify `available_glitches` array is populated
- Check console for "Next world glitch in X seconds"

**Glitch doesn't end:**
- Check if `process()` is being called
- Verify `time_remaining` is counting down
- Make sure `duration > 0`

**Enemy glitches don't work:**
- Enemies must be in "enemies" group
- Enemies need `speed` property for speed effects
- Check `requires_enemies` condition

**Control Inversion doesn't work:**
- Must be implemented in player movement code
- Check `is_glitch_active("Control Inversion")`
- See integration examples above

**Time effects (Slow/Fast) affect everything:**
- This is intentional! Uses `Engine.time_scale`
- Affects entire game engine
- UI animations also affected

## 🎮 Player Tips (Meta)

Since world glitches are uncontrollable, here's how players can adapt:

1. **Learn the warnings** - Visual/audio cues tell you what's coming
2. **Stay mobile** - Being static is dangerous during glitches
3. **Save resources** - Don't waste ammo during Bullet Spray
4. **Use player glitches** - Blink/Noclip can counter bad situations
5. **Expect chaos** - Embrace the unpredictability!

## 🔮 Future Ideas

- **Glitch combos**: Special effects when certain glitches combine
- **Glitch resistance**: Pickup that reduces glitch severity
- **Glitch prediction**: UI element showing next glitch
- **Glitch manipulation**: Player ability to influence which glitch spawns
- **Beneficial glitches**: Some glitches help the player
- **Glitch mutations**: Glitches evolve as they stay active
- **Glitch infection**: One glitch triggers another
- **Anti-glitch items**: Items that prevent specific glitches

## 📊 Statistics Ideas

Track for player feedback:
- Total glitches survived
- Most survived glitches simultaneously
- Deaths caused by specific glitches
- Longest time with active glitch
- Rarest glitch encountered

## 🎯 Testing Commands

Add these to your test scene:

```gdscript
# Test individual glitches
func test_screen_shake():
    world_glitch_manager.force_trigger_glitch("Screen Shake")

func test_enemy_multiplication():
    world_glitch_manager.force_trigger_glitch("Enemy Multiplication")

# Test by severity
func test_all_minor():
    for glitch in WorldGlitchTypes.get_minor_glitches():
        world_glitch_manager.start_glitch(glitch)
        await get_tree().create_timer(3.0).timeout

# Rapid fire test (chaos mode)
func chaos_test():
    world_glitch_manager.min_interval = 1.0
    world_glitch_manager.max_interval = 3.0
    world_glitch_manager.max_active_glitches = 5
```

---

## Summary

World glitches add **unpredictable chaos** to your roguelike. There are **16 world glitches** total. They:
- Happen automatically without player input
- Increase in frequency and severity as player progresses
- Create unique challenges every run
- Force players to adapt and think on their feet
- Add to the "glitchy" theme of the game

Combined with player-controlled glitches, this creates a dual-layer system:
- **Player glitches** = Tools you choose to use
- **World glitches** = Chaos you must survive

**The glitch system is ready to break your game... in the best way possible!** 🎮✨⚠️