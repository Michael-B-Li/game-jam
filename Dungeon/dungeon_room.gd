extends Node2D

## Dungeon Generator for Godot 4
## Generates a sequence of screen-sized rooms, one at a time,
## with a solid border and a clear floor.

# --- Node References ---
@onready var ground_layer: TileMapLayer = $TileMap/Ground
@onready var walls_layer: TileMapLayer = $TileMap/Wall
@onready var door_layer: TileMapLayer = $TileMap/Door
@onready var player: CharacterBody2D = $Player
@onready var fade_screen: ColorRect = $FadeScreen
@onready var camera: Camera2D = $Camera2D

# --- Tile Atlas Coordinates ---
const FLOOR_COORDS = Vector2i(1, 0) # The grey floor tile
const WALL_COORDS = Vector2i(0, 0)  # The red wall tile
const SOURCE_ID = 0

const DOOR_COORDS = Vector2i(0, 0)
const DOOR_SOURCE_ID = 0

# --- Dungeon Parameters ---
# @export var rooms_until_boss := 3
var current_room_level := 0

# --- State Tracking ---
var player_on_door := false
var is_transitioning := false


func _ready() -> void:
	# Set the fade screen to be invisible from the start
	fade_screen.modulate.a = 0.0
	# Generate the first room
	generate_room()


func _physics_process(delta):
	# Do nothing if we're already fading
	if is_transitioning:
		return

	# Check if player is on a door tile
	var player_tile_pos = door_layer.local_to_map(player.global_position)
	var source_id = door_layer.get_cell_source_id(player_tile_pos)
	
	if source_id == DOOR_SOURCE_ID:
		if not player_on_door:
			player_on_door = true
			transition_to_next_room()
	else:
		player_on_door = false


# --- This function handles the fade effect ---
func transition_to_next_room() -> void:
	is_transitioning = true
	
	var tween = create_tween()
	print("generating new room")
	tween.tween_property(fade_screen, "modulate:a", 1, 1) # Fade to black
	await tween.finished
	print("faded in")
	
	# Generate the new room *after* screen is black
	generate_room()
	
	# Fade back in
	tween = create_tween()
	tween.tween_property(fade_screen, "modulate:a", 0.0, 0.5) # Fade to clear
	await tween.finished
	print("faded out")
	
	is_transitioning = false


# --- THIS IS THE UPDATED ROOM GENERATION LOGIC ---
func generate_room() -> void:
	# 1. Clear the old room
	ground_layer.clear()
	walls_layer.clear()
	door_layer.clear()
	
	# 2. Get viewport and tile sizes
	var viewport_size: Vector2 = get_viewport_rect().size
	var tile_size: Vector2i = ground_layer.tile_set.tile_size
	
	if tile_size.x == 0 or tile_size.y == 0:
		push_warning("TileSet 'tile_size' is (0,0). Assuming 16x16.")
		tile_size = Vector2i(16, 16)

	# 3. Calculate SCREEN dimensions (in tiles)
	var floor_width_in_tiles = int(viewport_size.x / tile_size.x)
	var floor_height_in_tiles = int(viewport_size.y / tile_size.y)
	
	# 4. Create a floor rectangle centred at (0, 0)
	var floor_rect = Rect2i(
		-floor_width_in_tiles / 2,
		-floor_height_in_tiles / 2,
		floor_width_in_tiles,
		floor_height_in_tiles
	)
	
	# 5. Create the border rect by growing the floor rect
	var border_rect = floor_rect.grow(1) # Grow by 1 tile on all sides

	# 6. Carve the floor AND place the border walls
	_create_room_and_border(floor_rect, border_rect)
	
	# 7. Place obstacles (inside the floor_rect)
	# _place_obstacles(floor_rect) # --- REMOVED ---
	
	# 8. Place the door (making it 2 tiles wide and 3 tiles high)
	var door_x_right = floor_rect.end.x - 1
	var door_x_left = floor_rect.end.x - 2
	var door_y_centre = 0
	
	# Loop for Y dimension (height)
	for y_offset in range(-1, 2): # This gives -1, 0, 1
		var door_y = door_y_centre + y_offset
		
		# Place left side of door
		door_layer.set_cell(Vector2i(door_x_left, door_y), DOOR_SOURCE_ID, DOOR_COORDS)
		# Place right side of door
		door_layer.set_cell(Vector2i(door_x_right, door_y), DOOR_SOURCE_ID, DOOR_COORDS)
	
	# 9. Spawn the player (1 tile from left edge)
	var spawn_pos_grid = Vector2i(floor_rect.position.x + 1, 0)
	_spawn_player(spawn_pos_grid)

	# 10. Centre the camera
	camera.global_position = Vector2.ZERO
	camera.zoom = Vector2.ONE

	# 11. Increment room counter
	current_room_level += 1
	print("Entered room: ", current_room_level)


# --- Helper: Carves floor and builds walls ---
func _create_room_and_border(floor_rect: Rect2i, border_rect: Rect2i) -> void:
	# Loop through the *entire* border-inclusive rectangle
	for x in range(border_rect.position.x, border_rect.end.x):
		for y in range(border_rect.position.y, border_rect.end.y):
			var pos = Vector2i(x, y)
			
			if floor_rect.has_point(pos):
				# This is inside the floor area
				ground_layer.set_cell(pos, SOURCE_ID, FLOOR_COORDS)
			else:
				# This is in the border area
				walls_layer.set_cell(pos, SOURCE_ID, WALL_COORDS)


# --- Helper: Spawn the player ---
func _spawn_player(spawn_pos_grid: Vector2i) -> void:
	# Make sure the spawn point is clear of obstacles
	walls_layer.set_cell(spawn_pos_grid, -1) 
	# Make sure there is floor
	ground_layer.set_cell(spawn_pos_grid, SOURCE_ID, FLOOR_COORDS)
	
	# Convert to pixel coordinates
	var spawn_pos_pixels = ground_layer.map_to_local(spawn_pos_grid)
	
	if player.has_method("start"):
		player.start(spawn_pos_pixels)
	else:
		player.position = spawn_pos_pixels
		player.show()
