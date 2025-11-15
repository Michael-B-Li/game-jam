extends Node
class_name WorldGlitchManager

## Manages random world glitches that happen without player control
## These glitches add chaos and unpredictability to the roguelike

const WorldGlitch = preload("res://glitches/world_glitch.gd")

signal world_glitch_started(glitch: WorldGlitch)
signal world_glitch_ended(glitch: WorldGlitch)
signal glitch_intensity_changed(level: int)

## Configuration
@export var enabled: bool = true
@export var min_interval: float = 15.0  ## Minimum seconds between glitches
@export var max_interval: float = 45.0  ## Maximum seconds between glitches
@export var max_active_glitches: int = 2  ## Max simultaneous glitches
@export var current_floor: int = 1  ## Current dungeon floor (affects glitch pool)

## Glitch intensity levels (increases as player progresses)
@export var glitch_intensity: int = 1  ## 1=Minor only, 2=+Moderate, 3=+Severe

var available_glitches: Array[WorldGlitch] = []
var active_glitches: Array[WorldGlitch] = []
var time_until_next_glitch: float = 0.0
var world: Node = null

func _ready() -> void:
	world = get_tree().root

	# Load all available glitches
	load_glitches_by_intensity(glitch_intensity)

	# Schedule first glitch
	schedule_next_glitch()

func _process(delta: float) -> void:
	if not enabled:
		return

	# Countdown to next glitch
	if time_until_next_glitch > 0.0:
		time_until_next_glitch -= delta
		if time_until_next_glitch <= 0.0:
			trigger_random_glitch()

	# Process active glitches
	var glitches_to_remove: Array[WorldGlitch] = []
	for glitch in active_glitches:
		glitch.process(world, delta)

		if not glitch.is_active:
			glitches_to_remove.append(glitch)

	# Remove expired glitches
	for glitch in glitches_to_remove:
		end_glitch(glitch)

func _physics_process(delta: float) -> void:
	if not enabled:
		return

	# Physics process for active glitches
	for glitch in active_glitches:
		glitch.physics_process(world, delta)

## Load glitches based on current intensity level
func load_glitches_by_intensity(level: int) -> void:
	available_glitches.clear()

	match level:
		1:  # Minor only
			available_glitches = WorldGlitchTypes.get_minor_glitches()
		2:  # Minor + Moderate
			available_glitches = WorldGlitchTypes.get_minor_glitches()
			available_glitches.append_array(WorldGlitchTypes.get_moderate_glitches())
		3:  # All glitches
			available_glitches = WorldGlitchTypes.get_all_world_glitches()
		_:
			available_glitches = WorldGlitchTypes.get_minor_glitches()

	print("World Glitch Manager: Loaded ", available_glitches.size(), " glitches at intensity ", level)

## Trigger a random glitch
func trigger_random_glitch() -> void:
	# Check if we can spawn more glitches
	if active_glitches.size() >= max_active_glitches:
		schedule_next_glitch()
		return

	# Build weighted pool of eligible glitches
	var eligible_glitches: Array[WorldGlitch] = []
	var weights: Array[int] = []

	for glitch in available_glitches:
		if glitch.can_spawn(world, current_floor):
			# Don't allow same glitch to stack unless allowed
			if not glitch.can_stack and is_glitch_active(glitch.glitch_name):
				continue

			eligible_glitches.append(glitch)
			weights.append(glitch.spawn_weight)

	if eligible_glitches.is_empty():
		print("No eligible glitches available")
		schedule_next_glitch()
		return

	# Select glitch using weighted random
	var selected_glitch = weighted_random_choice(eligible_glitches, weights)
	if selected_glitch:
		start_glitch(selected_glitch)

	# Schedule next glitch
	schedule_next_glitch()

## Start a specific glitch
func start_glitch(glitch: WorldGlitch) -> void:
	# Create a new instance to avoid state conflicts
	var glitch_instance = glitch.duplicate()

	active_glitches.append(glitch_instance)
	glitch_instance.activate(world)

	world_glitch_started.emit(glitch_instance)
	print("========================================")
	print("⚠️  WORLD GLITCH ACTIVE: ", glitch_instance.glitch_name)
	print("    ", glitch_instance.description)
	print("    Duration: ", glitch_instance.duration, "s")
	print("    Severity: ", get_severity_text(glitch_instance.severity))
	print("========================================")

## End a glitch
func end_glitch(glitch: WorldGlitch) -> void:
	if glitch in active_glitches:
		active_glitches.erase(glitch)

	glitch.deactivate(world)
	world_glitch_ended.emit(glitch)
	print("World glitch ended: ", glitch.glitch_name)

## Schedule the next random glitch
func schedule_next_glitch() -> void:
	time_until_next_glitch = randf_range(min_interval, max_interval)
	print("Next world glitch in ", int(time_until_next_glitch), " seconds")

## Check if a glitch type is currently active
func is_glitch_active(glitch_name: String) -> bool:
	for glitch in active_glitches:
		if glitch.glitch_name == glitch_name:
			return true
	return false

## Get active glitch by name
func get_active_glitch(glitch_name: String) -> WorldGlitch:
	for glitch in active_glitches:
		if glitch.glitch_name == glitch_name:
			return glitch
	return null

## Weighted random selection
func weighted_random_choice(items: Array, weights: Array) -> Variant:
	if items.is_empty() or items.size() != weights.size():
		return null

	var total_weight: int = 0
	for weight in weights:
		total_weight += weight

	var random_value: int = randi() % total_weight
	var cumulative_weight: int = 0

	for i in range(items.size()):
		cumulative_weight += weights[i]
		if random_value < cumulative_weight:
			return items[i]

	return items[0]

## Increase glitch intensity (call when floor increases)
func increase_intensity() -> void:
	if glitch_intensity < 3:
		glitch_intensity += 1
		load_glitches_by_intensity(glitch_intensity)
		glitch_intensity_changed.emit(glitch_intensity)
		print("Glitch intensity increased to ", glitch_intensity)

## Decrease glitch frequency (make game easier)
func make_less_frequent() -> void:
	min_interval *= 1.5
	max_interval *= 1.5
	print("Glitch frequency decreased")

## Increase glitch frequency (make game harder)
func make_more_frequent() -> void:
	min_interval *= 0.7
	max_interval *= 0.7
	print("Glitch frequency increased")

## Force trigger a specific glitch by name
func force_trigger_glitch(glitch_name: String) -> bool:
	for glitch in available_glitches:
		if glitch.glitch_name == glitch_name:
			start_glitch(glitch)
			return true
	return false

## Clear all active glitches
func clear_all_glitches() -> void:
	for glitch in active_glitches.duplicate():
		end_glitch(glitch)
	print("All world glitches cleared")

## Pause/resume glitch system
func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		clear_all_glitches()
	print("World glitch system ", "enabled" if enabled else "disabled")

## Get severity text
func get_severity_text(severity: int) -> String:
	match severity:
		1: return "Minor"
		2: return "Moderate"
		3: return "Severe"
		4: return "CRITICAL"
		_: return "Unknown"

## Get glitch info for UI
func get_active_glitch_info() -> Array[Dictionary]:
	var info: Array[Dictionary] = []
	for glitch in active_glitches:
		info.append({
			"name": glitch.glitch_name,
			"description": glitch.description,
			"time_remaining": glitch.time_remaining,
			"duration": glitch.duration,
			"severity": glitch.severity,
			"color": glitch.get_severity_color()
		})
	return info

## Update floor level (affects which glitches can spawn)
func set_floor(level: int) -> void:
	current_floor = level

	# Increase intensity every 3 floors
	var new_intensity = mini(1 + int(level / 3.0), 3)
	if new_intensity != glitch_intensity:
		glitch_intensity = new_intensity
		load_glitches_by_intensity(glitch_intensity)
		glitch_intensity_changed.emit(glitch_intensity)

	print("Floor set to ", level, " - Glitch intensity: ", glitch_intensity)
