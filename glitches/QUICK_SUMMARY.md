# Glitch System - Quick Summary

## 🎮 Two Types of Glitches

### 1. Player Glitches (YOU Control)
**Keys:** Q, E, F, Z, X, C

✅ **You activate these abilities**
- Costs energy (100 max, regens 10/sec)
- Has cooldowns
- Strategic use

**3 Starter Glitches:**
- **Q** - Blink: Teleport towards mouse
- **E** - Noclip: Phase through walls (4s)
- **F** - Duplication: Copy nearby bullets

**4 Unlockable Glitches:**
- **Z** - Time Desync: Slow enemies, speed up player
- **X** - Buffer Overflow: Fire bullets 360°
- **C** - Memory Leak: Leave damaging trail
- More coming...

### 2. World Glitches (GAME Controls)
**Timing:** Random, every 15-45 seconds

⚠️ **These happen TO you**
- No control, no cost
- Last 5-15 seconds
- Get harder on higher floors

**16 Random Effects:**

**Minor (Severity 1):** 
- Screen Tear, Slow Motion, Color Corruption, Low Resolution

**Moderate (Severity 2):**
- Fast Forward, Bullet Spray, Control Inversion, Enemy Speed Boost, Ammo Drain, Gravity Flip, Bullet Noclip, Misplaced Room Trigger

**Severe (Severity 3):**
- Invisible Enemies, Random Teleport, Enemy Multiplication, Spawn Rain

## 📝 Setup

### Player Glitches (Already Done!)
```gdscript
# Already integrated in player.gd
# Just press Q, E, F in game!
```

### World Glitches (Add to Main Scene)
```gdscript
# In your main game scene:
var world_glitch_manager: WorldGlitchManager

func _ready() -> void:
    world_glitch_manager = WorldGlitchManager.new()
    add_child(world_glitch_manager)
    
    world_glitch_manager.enabled = true
    world_glitch_manager.current_floor = 1
```

## 🎯 Quick Test

### Test Player Glitches:
1. Run game (F5)
2. Press **Q** - You should teleport towards mouse
3. Press **E** - You should turn blue and walk through walls
4. Press **F** - Nearby bullets should duplicate
5. Watch console for "GLITCH ACTIVATED: [name]"

### Test World Glitches:
1. Add WorldGlitchManager to scene
2. Set min_interval = 5.0 (for fast testing)
3. Wait 5-10 seconds
4. Console shows "⚠️ WORLD GLITCH ACTIVE: [name]"
5. Glitch effects happen automatically

## 📊 Game Flow

```
Floor 1-2: Player has 3 basic glitches
           World glitches = Minor only
           
Floor 3-5: Unlock more player glitches
           World glitches = Minor + Moderate
           
Floor 6+:  All player glitches available
           World glitches = All including Severe
```

## 🔑 Key Concepts

**Player Glitches = Your Tools**
- You choose when to use
- Strategic advantage
- Energy management

**World Glitches = Environmental Chaos**
- Random and unpredictable
- Must adapt on the fly
- Part of roguelike challenge

**Together = Unique Gameplay**
- Use your glitches to counter world glitches
- Chaos + Control = Fun!

## 📚 Full Documentation

- **README.md** - Complete player glitch guide (7 glitches)
- **WORLD_GLITCHES_README.md** - Complete world glitch guide (16 glitches)
- **example_world_glitch_usage.gd** - Integration examples

## 🚀 Getting Started

1. **Test player glitches** - Already integrated, just press Q/E/F
2. **Add world glitches** - Copy code from example_world_glitch_usage.gd
3. **Adjust settings** - Change intervals, intensity, max active glitches
4. **Have fun!** - Break the game (on purpose)

---

**TL;DR:** 
- Press Q/E/F = Use glitches as abilities
- Every 15-45s = Random glitch happens to you
- Survive the chaos! 🎮✨⚠️