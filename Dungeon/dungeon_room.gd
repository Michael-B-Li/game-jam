extends Node2D

## Dungeon Generator for Godot 4
## Spawns 3 enemies per room in fixed locations.

signal room_changed(room_number: int)

# --- Baddie Spawning ---
@export var baddie_scene: PackedScene

# --- Node References ---
@onready var ground_layer: TileMapLayer = $TileMap/Ground
@onready var walls_layer: TileMapLayer = $TileMap/Wall
@onready var door_layer: TileMapLayer = $TileMap/Door
@onready var player: CharacterBody2D = $Player
@onready var fade_screen: ColorRect = $FadeScreen
@onready var camera: Camera2D = $Camera2D
@onready var room_label: Label = $UI/RoomLabel # Assumes RoomLabel is a direct child

# This path MUST match the name of your container node in the scene tree
@onready var enemy_container: Node2D = $EnemyContainer 

# --- Tile Atlas Coordinates ---
const FLOOR_COORDS = Vector2i(1, 0) # The grey floor tile
const WALL_COORDS = Vector2i(0, 0)  # The red wall tile
const SOURCE_ID = 0

const DOOR_COORDS = Vector2i(0, 0)
const DOOR_SOURCE_ID = 0

# --- Dungeon Parameters ---
var current_room_level := 0
var num_room_types = 2 # 0=Empty, 1=Blocks (3x3)

# --- State Tracking ---
var player_on_door := false
var is_transitioning := false


func _ready() -> void:
	# Set the fade screen to be invisible from the start
	fade_screen.modulate.a = 0.0
	
	# Generate the first room
	generate_room()
	
	# Connects this script's "room_changed" signal to the
	# "update_text" function in the RoomLabel.gd script.
	if room_label:
		room_changed.connect(room_label.update_text)
	else:
		push_warning("RoomLabel node not found. Did you delete it?")


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
	tween.tween_property(fade_screen, "modulate:a", 1, 1) # Fade to black
	await tween.finished
	
	# Generate the new room *after* screen is black
	generate_room()
	
	# Fade back in
	tween = create_tween()
	tween.tween_property(fade_screen, "modulate:a", 0.0, 0.5) # Fade to clear
	await tween.finished
	
	is_transitioning = false


# --- THIS IS THE UPDATED ROOM GENERATION LOGIC ---
func generate_room() -> void:
	# 1. --- Clear old enemies ---
	_clear_old_enemies()
	
	# 2. Clear the old room tiles
	ground_layer.clear()
	walls_layer.clear()
	door_layer.clear()
	
	# 3. Get viewport and tile sizes
	var viewport_size: Vector2 = get_viewport_rect().size
	var tile_size: Vector2i = ground_layer.tile_set.tile_size
	
	if tile_size.x == 0 or tile_size.y == 0:
		push_warning("TileSet 'tile_size' is (0,0). Assuming 16x16.")
		tile_size = Vector2i(16, 16)

	# 4. Calculate SCREEN dimensions (in tiles)
	var floor_width_in_tiles = int(viewport_size.x / tile_size.x)
	var floor_height_in_tiles = int(viewport_size.y / tile_size.y)
	
	# 5. Create a floor rectangle centred at (0, 0)
	var floor_rect = Rect2i(
		-floor_width_in_tiles / 2,
		-floor_height_in_tiles / 2,
		floor_width_in_tiles,
		floor_height_in_tiles
	)
	
	# 6. Create the border rect by growing the floor rect
	var border_rect = floor_rect.grow(1) # Grow by 1 tile on all sides

	# 7. Carve the floor AND place the border walls
	_create_room_and_border(floor_rect, border_rect)
	
	# 8. Pick a room type and add its features
	var room_type = randi() % num_room_types # 0 or 1
	
	match room_type:
		0:
			# Type 0: Empty Room
			pass # Do nothing, just leave it empty
		1:
			# Type 1: Block Room (3x3)
			_add_blocks(floor_rect)
	
	# 9. --- Spawn enemies ---
	# Spawn after obstacles are placed
	_spawn_enemies(floor_rect)
	
	# 10. Place the door (making it 2 tiles wide and 3 tiles high)
	var door_x_right = floor_rect.end.x - 1
	var door_x_left = floor_rect.end.x - 2
	var door_y_centre = 0
	
	# Loop for Y dimension (height)
	for y_offset in range(-1, 2): # This gives -1, 0, 1
		var door_y = door_y_centre + y_offset
		door_layer.set_cell(Vector2i(door_x_left, door_y), DOOR_SOURCE_ID, DOOR_COORDS)
		door_layer.set_cell(Vector2i(door_x_right, door_y), DOOR_SOURCE_ID, DOOR_COORDS)
	
	# 11. Spawn the player (1 tile from left edge)
	var spawn_pos_grid = Vector2i(floor_rect.position.x + 1, 0)
	_spawn_player(spawn_pos_grid)

	# 12. Centre the camera
	camera.global_position = Vector2.ZERO
	camera.zoom = Vector2.ONE

	# 13. Increment room counter
	current_room_level += 1
	
	# Send the new room number to any connected nodes (like our label)
	room_changed.emit(current_room_level)


# --- Helper: Carves floor and builds walls ---
func _create_room_and_border(floor_rect: Rect2i, border_rect: Rect2i) -> void:
	for x in range(border_rect.position.x, border_rect.end.x):
		for y in range(border_rect.position.y, border_rect.end.y):
			var pos = Vector2i(x, y)
			if floor_rect.has_point(pos):
				ground_layer.set_cell(pos, SOURCE_ID, FLOOR_COORDS)
			else:
				walls_layer.set_cell(pos, SOURCE_ID, WALL_COORDS)


# --- UPDATED ROOM TYPE: Add 3x3 Blocks ---
func _add_blocks(floor_rect: Rect2i) -> void:
	var num_blocks = 4 # How many 3x3 blocks to place
	var padding = 5 # How close to the edge they can spawn
	
	var spawn_y = 0 # Central path
	var door_x_left = floor_rect.end.x - 2
	
	for i in range(num_blocks):
		# Pick a random top-left corner for the 3x3 block
		var x = randi_range(floor_rect.position.x + padding, floor_rect.end.x - (padding + 2))
		var y = randi_range(floor_rect.position.y + padding, floor_rect.end.y - (padding + 2))
		
		var pos = Vector2i(x, y)
		var block_rect = Rect2i(pos, Vector2i(3, 3))
		
		# --- Safety Checks ---
		# Don't place on the central path
		var spawn_pos = Vector2i(floor_rect.position.x + 1, spawn_y)
		if block_rect.has_point(spawn_pos):
			continue # Skip this block, it's on the player spawn
		
		# Don't place in front of the door
		var door_blocked = false
		for y_offset in range(-1, 2):
			var door_pos_left = Vector2i(door_x_left, spawn_y + y_offset)
			var door_pos_right = Vector2i(door_x_left + 1, spawn_y + y_offset)
			if block_rect.has_point(door_pos_left) or block_rect.has_point(door_pos_right):
				door_blocked = true
				break
		if door_blocked:
			continue # Skip this block, it's on the door
			
		# Place the 3x3 block
		for j in range(3):
			for k in range(3):
				walls_layer.set_cell(pos + Vector2i(j, k), SOURCE_ID, WALL_COORDS)


# --- Helper: Clear Old Enemies ---
func _clear_old_enemies() -> void:
	# This is why we use a container!
	if enemy_container == null:
		return
		
	for enemy in enemy_container.get_children():
		enemy.queue_free()


# --- NEW RELIABLE SPAWN FUNCTION ---
func _spawn_enemies(floor_rect: Rect2i) -> void:
	# --- Main Safety Checks ---
	if baddie_scene == null:
		push_warning("Baddie Scene not set in Dungeon.gd! Assign baddie1.tscn in the Inspector.")
		return
	if enemy_container == null:
		push_warning("EnemyContainer node not found! Add a Node2D named 'EnemyContainer' to Dungeon.")
		return

	print("Spawning 3 enemies.")

	# Define 3 safe, hard-coded spawn locations (in tile coordinates)
	# (These are far from the player spawn and door)
	var spawn_points_tile = [
		Vector2i(floor_rect.position.x + 5, floor_rect.position.y + 5), # Top-left
		Vector2i(floor_rect.end.x - 10, floor_rect.position.y + 5),     # Top-right (away from door)
		Vector2i(floor_rect.position.x + 5, floor_rect.end.y - 5)       # Bottom-left
	]

	for tile_pos in spawn_points_tile:
		# Check if an obstacle was (unluckily) placed on this exact spot
		if walls_layer.get_cell_source_id(tile_pos) != -1:
			print("Spawn point %s is blocked by a wall. Skipping." % tile_pos)
			continue # Skip this spawn, try the next one
			
		# All clear! Create the baddie.
		var instance = baddie_scene.instantiate()
		
		# Set its position to the center of the safe tile
		instance.global_position = ground_layer.map_to_local(tile_pos)
		
		# Add it to the container
		enemy_container.add_child(instance)


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
