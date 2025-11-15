extends Resource
class_name WorldGlitch

## Base class for environmental/world glitches that happen randomly
## Players have no control over these - they just happen!

@export var glitch_name: String = "World Glitch"
@export var description: String = "A random glitch effect"
@export var duration: float = 5.0  ## How long the glitch lasts
@export var severity: int = 1  ## 1=Minor, 2=Moderate, 3=Severe, 4=Critical
@export var can_stack: bool = false  ## Can multiple instances be active?
@export var visual_effect: String = "none"  ## "screen_shake", "distortion", "invert", etc.

## Weight system for random selection (higher = more likely)
@export var spawn_weight: int = 10

## Conditions for when this glitch can appear
@export var min_floor: int = 1  ## Earliest floor this can appear
@export var requires_enemies: bool = false  ## Only spawn when enemies present
@export var requires_player_shooting: bool = false  ## Only when player is shooting

var is_active: bool = false
var time_remaining: float = 0.0
var affected_objects: Array = []

## Called when glitch starts
func activate(world: Node2D) -> void:
	is_active = true
	time_remaining = duration
	print("WORLD GLITCH: ", glitch_name, " activated!")

## Called when glitch ends
func deactivate(world: Node2D) -> void:
	is_active = false
	cleanup()
	print("WORLD GLITCH: ", glitch_name, " ended")

## Called every frame while active
func process(world: Node2D, delta: float) -> void:
	time_remaining -= delta
	if time_remaining <= 0.0:
		is_active = false

## Called every physics frame while active
func physics_process(world: Node2D, delta: float) -> void:
	pass

## Check if glitch can spawn under current conditions
func can_spawn(world: Node2D, current_floor: int) -> bool:
	if current_floor < min_floor:
		return false

	if requires_enemies:
		var enemies = world.get_tree().get_nodes_in_group("enemies")
		if enemies.size() == 0:
			return false

	return true

## Cleanup any created objects
func cleanup() -> void:
	for obj in affected_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	affected_objects.clear()

## Get visual indicator color based on severity
func get_severity_color() -> Color:
	match severity:
		1: return Color(0.5, 0.5, 1.0, 0.3)  # Blue - Minor
		2: return Color(1.0, 1.0, 0.0, 0.4)  # Yellow - Moderate
		3: return Color(1.0, 0.5, 0.0, 0.5)  # Orange - Severe
		4: return Color(1.0, 0.0, 0.0, 0.6)  # Red - Critical
		_: return Color.WHITE
