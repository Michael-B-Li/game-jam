# Ammo UI - Quick Setup Guide

## ✅ What's Been Created

All the ammo display UI files are ready! Here's what you have:

- `ui/ammo_display.gd` - Script that displays ammo count
- `ui/ammo_display.tscn` - UI scene with layout
- `ui/README.md` - Complete documentation

## 🚀 3-Step Setup

### Step 1: Add Snowbell Font (Optional but Recommended)

1. Download Snowbell font from: https://www.fontspace.com/snowbell-font-f148771
2. Create folder: `game-jam/fonts/`
3. Copy `Snowbell.ttf` into the `fonts/` folder
4. Open `ammo_display.tscn` in Godot
5. Select `AmmoLabel` node
6. Inspector → Theme Overrides → Fonts → Font → Load → Select `res://fonts/Snowbell.ttf`

**Skip this step if you want to use default font - it still works fine!**

### Step 2: Add Ammo Display to Game

1. Open your main game scene in Godot (the one with the player)
2. Right-click the root node → Add Child Node → Select "Node"
3. Or click the chain link icon "Instantiate Child Scene"
4. Navigate to `ui/ammo_display.tscn` and select it
5. Done! The UI will appear in bottom-right corner

### Step 3: Test It!

1. Run the game (F5)
2. You should see ammo count in bottom-right: **"12 / 12"**
3. Shoot - watch the number decrease
4. When empty, it turns RED and auto-reloads
5. Switch guns (1-4 keys) - ammo updates for each gun

## 🎨 Current Look

```
Bottom-right corner:
┌─────────────┐
│  🔸 12 / 12 │  ← Bullet icon + ammo count
└─────────────┘
```

**Colors:**
- White = Normal ammo
- Yellow = Low ammo (< 30%)
- Red = Empty (0 ammo)

## ⚙️ Already Working Features

✅ Ammo count updates when shooting
✅ Updates when reloading
✅ Updates when switching guns
✅ Shows different ammo for each gun
✅ Color changes based on ammo level
✅ Bullet icon displayed
✅ Black outline for visibility
✅ Positioned in bottom-right

## 🎯 Optional Customization

### Move Position
Edit `ammo_display.tscn` → Select `AmmoContainer` → Change offset values

### Change Font Size
`AmmoLabel` → Inspector → Font Size → Change from 32 to desired size

### Change Colors
Edit `ammo_display.gd` → `update_ammo_display()` function → Modify Color values

### Use Custom Bullet Sprite
1. Download bullet icon from OpenGameArt or itch.io
2. Save as `bullet_icon.png` in `Assets/`
3. Change `BulletIcon` node type to TextureRect
4. Load your sprite as texture

## 🐛 Troubleshooting

**"Ammo doesn't show"**
- Make sure you added ammo_display.tscn to your game scene
- Player must be in "player" group (already done in player.gd!)

**"Font looks blurry"**
- In font import settings: Antialiasing → None
- Disable MSDF
- Enable Force Autohinter

**"Icon doesn't appear"**
- The bullet is drawn with ColorRect nodes
- It should appear automatically
- Check that BulletIcon node exists in scene

## 📝 Summary

The ammo UI is **ready to use right now**! Just:
1. Open Godot
2. Add `ui/ammo_display.tscn` to your game scene
3. Run and play!

Font is optional - it works with default Godot font too.

---

**TL;DR:** Drag `ui/ammo_display.tscn` into your game scene. Done! 🎯✨
