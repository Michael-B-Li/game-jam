extends Node2D

## Dungeon Generator for Godot 4
## This script creates a single room in the middle of a map.
## It expects a "TileMap" child with "Ground" and "Walls" layers.
## It also expects a "Player" scene as a child.

# --- Node References ---
@onready var ground_layer: TileMapLayer = $TileMap/Ground
@onready var walls_layer: TileMapLayer = $TileMap/Walls
@onready var player: CharacterBody2D = $Player # Make sure this matches your player type

# --- Tile Atlas Coordinates ---
const FLOOR_COORDS = Vector2i(1, 0) # Your ground/floor tile
const WALL_COORDS = Vector2i(0, 0)  # Your wall tile
const SOURCE_ID = 0                 # This is 0 if you only have one tilesheet

# --- Dungeon Parameters ---
@export var map_width := 30
@export var map_height := 20

@export var room_width := 20
@export var room_height := 15

# This will hold our one room
var room: Rect2i


func _ready() -> void:
	generate_single_room()


func generate_single_room() -> void:
	# Clear any old data
	ground_layer.clear()
	walls_layer.clear()
	
	# 1. Fill the entire map with walls
	_fill_map_with_walls()
	
	# 2. Define our single room
	# Calculate top-left corner to centre the room
	var room_x = (map_width - room_width) / 2
	var room_y = (map_height - room_height) / 2
	room = Rect2i(room_x, room_y, room_width, room_height)
	
	# 3. Carve out the room
	_carve_room(room)
	
	# 4. Spawn the player
	_spawn_player()


# --- Step 1: Fill the Map ---
func _fill_map_with_walls() -> void:
	for x in range(map_width):
		for y in range(map_height):
			walls_layer.set_cell(Vector2i(x, y), SOURCE_ID, WALL_COORDS)


# --- Step 3: Carve a Room ---
func _carve_room(room_rect: Rect2i) -> void:
	# room_rect.position is the top-left corner
	# room_rect.end is the bottom-right corner
	for x in range(room_rect.position.x, room_rect.end.x):
		for y in range(room_rect.position.y, room_rect.end.y):
			# Set a floor tile on the Ground layer
			ground_layer.set_cell(Vector2i(x, y), SOURCE_ID, FLOOR_COORDS)
			# Remove the wall tile from the Walls layer
			walls_layer.set_cell(Vector2i(x, y), -1) # -1 clears a tile


# --- Step 4: Spawn the Player ---
func _spawn_player() -> void:
	# Get the centre in *tile coordinates*
	var spawn_pos_grid = room.get_center()
	
	# Convert tile coordinates to *pixel coordinates*
	var spawn_pos_pixels = ground_layer.map_to_local(spawn_pos_grid)
	
	# Call the player's start function with the pixel position
	if player.has_method("start"):
		player.start(spawn_pos_pixels)
	else:
		# Failsafe if the 'start' function isn't found
		player.position = spawn_pos_pixels
		player.show()
