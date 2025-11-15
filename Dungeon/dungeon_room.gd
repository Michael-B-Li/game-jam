extends Node2D

## Dungeon Generator for Godot 4
## Generates a sequence of rooms, one at a time.
## Fades to black when transitioning between rooms.

# --- Node References ---
@onready var ground_layer: TileMapLayer = $TileMap/Ground
@onready var walls_layer: TileMapLayer = $TileMap/Wall
@onready var door_layer: TileMapLayer = $TileMap/Door
@onready var player: CharacterBody2D = $Player
@onready var fade_screen: ColorRect = $FadeScreen # <-- NEW

# --- Tile Atlas Coordinates ---
const FLOOR_COORDS = Vector2i(1, 0)
const WALL_COORDS = Vector2i(0, 0)
const SOURCE_ID = 0

const DOOR_COORDS = Vector2i(0, 0)
const DOOR_SOURCE_ID = 0

# --- Dungeon Parameters ---
@export var room_width := 20
@export var room_height := 15
@export var boss_room_width := 30
@export var boss_room_height := 20
@export var map_size := Vector2i(40, 30)

# --- State Tracking ---
@export var rooms_until_boss := 3
var current_room_level := 0
var player_on_door := false
var is_transitioning := false # <-- NEW: Prevents multiple fades


func _ready() -> void:
	generate_room()


func _physics_process(delta):
	# Do nothing if we're already fading
	if is_transitioning:
		return

	var player_tile_pos = door_layer.local_to_map(player.global_position)
	var source_id = door_layer.get_cell_source_id(player_tile_pos)
	
	if source_id == DOOR_SOURCE_ID:
		if not player_on_door:
			player_on_door = true
			# Call the new transition function INSTEAD of generate_room()
			transition_to_next_room()
	else:
		player_on_door = false


# --- NEW: This function handles the fade effect ---
func transition_to_next_room() -> void:
	is_transitioning = true
	
	# 1. Fade to black
	var tween = create_tween()
	print("generating new room")
	## Animate the 'modulate' property, specifically its 'alpha' (a) channel
	tween.tween_property(fade_screen, "modulate:a", 1, 1)
	await tween.finished # Wait for the fade-in to complete
	print("faded in")
	## 2. Generate the new room (while the screen is black)
	generate_room()
	
	# 3. Fade back to transparent
	tween = create_tween()
	tween.tween_property(fade_screen, "modulate:a", 0.0, 0.5)
	await tween.finished # Wait for the fade-out to complete
	print("faded out")
	# 4. We are done
	is_transitioning = false


# This is the main function that builds a new room
func generate_room() -> void:
	# 1. Clear the old room
	ground_layer.clear()
	walls_layer.clear()
	door_layer.clear()
	
	# 2. Decide which room to build
	var is_boss_room = (current_room_level == rooms_until_boss)
	var room_rect: Rect2i
	
	if is_boss_room:
		var x = (map_size.x - boss_room_width) / 2
		var y = (map_size.y - boss_room_height) / 2
		room_rect = Rect2i(x, y, boss_room_width, boss_room_height)
	else:
		var x = (map_size.x - room_width) / 2
		var y = (map_size.y - room_height) / 2
		room_rect = Rect2i(x, y, room_width, room_height)

	# 3. Fill map with walls and carve the room
	_fill_map_with_walls()
	_carve_room(room_rect)
	
	# 4. Place door (if not boss room)
	if not is_boss_room:
		var door_pos_grid = Vector2i(room_rect.end.x - 1, room_rect.get_center().y)
		door_layer.set_cell(door_pos_grid, DOOR_SOURCE_ID, DOOR_COORDS)

	# 5. Spawn the player
	var spawn_pos_grid = Vector2i(room_rect.position.x + 2, room_rect.get_center().y)
	var spawn_pos_pixels = ground_layer.map_to_local(spawn_pos_grid)
	
	if player.has_method("start"):
		player.start(spawn_pos_pixels)
	else:
		player.position = spawn_pos_pixels
		player.show()

	# 6. Increment room counter
	current_room_level += 1


# --- Helper: Fill the Map ---
func _fill_map_with_walls() -> void:
	for x in range(map_size.x):
		for y in range(map_size.y):
			walls_layer.set_cell(Vector2i(x, y), SOURCE_ID, WALL_COORDS)


# --- Helper: Carve a Room ---
func _carve_room(room_rect: Rect2i) -> void:
	for x in range(room_rect.position.x, room_rect.end.x):
		for y in range(room_rect.position.y, room_rect.end.y):
			ground_layer.set_cell(Vector2i(x, y), SOURCE_ID, FLOOR_COORDS)
			walls_layer.set_cell(Vector2i(x, y), -1)
