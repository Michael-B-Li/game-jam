# Bullet Icon Reference

## Simple 16x16 Pixel Bullet Icon

You can create this in any pixel art editor (Aseprite, Piskel, GIMP, etc.)

```
Pixel Grid (16x16):
. = transparent
Y = Yellow/Gold (#D4AF37)
B = Brown/Brass (#B8860B)
D = Dark Brown (#8B6914)

    0123456789ABCDEF
  0 ................
  1 ................
  2 .......YY.......
  3 ......YYYY......
  4 ......YYYY......
  5 .....YYYYYY.....
  6 .....YYYYYY.....
  7 .....BBBBBB.....
  8 .....BBBBBB.....
  9 .....BBBBBB.....
  A .....BBBBBB.....
  B .....BBBBBB.....
  C .....BBBBBB.....
  D ....DDDDDDDD....
  E ....DDDDDDDD....
  F ................
```

## Color Palette

- Tip (Golden): `#D4AF37` or RGB(212, 175, 55)
- Casing (Brass): `#B8860B` or RGB(184, 134, 11)
- Base (Dark): `#8B6914` or RGB(139, 105, 20)

## Alternative: Download Ready-Made Icons

### Free Pixel Art Bullet Icons:

1. **OpenGameArt**
   - https://opengameart.org/content/ammo-sprite
   - License: Public Domain / CC0

2. **itch.io**
   - https://itch.io/game-assets/tag-bullet/tag-pixel-art
   - Search: "bullet icon pixel art free"

3. **Kenney Assets**
   - https://www.kenney.nl/assets
   - Search for weapon/bullet packs
   - All CC0 licensed

## Quick Creation Steps

### Using GIMP (Free):
1. File → New → 16x16 pixels
2. View → Show Grid
3. Pencil tool, 1px size
4. Draw the bullet pattern above
5. Export as PNG

### Using Piskel (Free Online):
1. Go to https://www.piskelapp.com/
2. Create 16x16 sprite
3. Draw bullet
4. Download as PNG

### Using Aseprite (Paid):
1. New sprite 16x16
2. Draw bullet with pencil tool
3. Export as PNG

## Save Location

Save your bullet icon as:
```
game-jam/Assets/bullet_icon.png
```

Then in Godot:
1. Open `ui/ammo_display.tscn`
2. Select `BulletIcon` node
3. Change type to `TextureRect`
4. Load `res://Assets/bullet_icon.png` as Texture

## Current Built-in Icon

The code already creates a bullet using ColorRect nodes, so this is **optional**.
The UI works without a custom sprite!

Built-in bullet dimensions:
- Tip: 6x8 pixels (golden)
- Casing: 10x16 pixels (brass)
- Rim: 12x4 pixels (dark brass)
- Total height: 24 pixels