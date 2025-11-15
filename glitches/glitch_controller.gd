extends Node
class_name GlitchController

## Manages glitch activation, cooldowns, and energy system

const Glitch = preload("res://glitches/glitch.gd")

signal glitch_activated(glitch: Glitch)
signal glitch_deactivated(glitch: Glitch)
signal energy_changed(current: int, max_energy: int)
signal cooldown_updated(glitch: Glitch, percent: float)

@export var max_energy: int = 100
@export var energy_regen_rate: float = 10.0  ## Energy per second
@export var available_glitches: Array[Glitch] = []

var current_energy: int = 100
var active_glitches: Array[Glitch] = []
var player: Node2D = null

func _ready() -> void:
	current_energy = max_energy
	player = get_parent() as Node2D

func _process(delta: float) -> void:
	# Regenerate energy
	if current_energy < max_energy:
		current_energy = mini(current_energy + int(energy_regen_rate * delta), max_energy)
		energy_changed.emit(current_energy, max_energy)

	# Update all glitch cooldowns
	for glitch in available_glitches:
		if glitch.current_cooldown > 0.0:
			glitch.update_cooldown(delta)
			cooldown_updated.emit(glitch, glitch.get_cooldown_percent())

	# Process active glitches
	var glitches_to_deactivate: Array[Glitch] = []
	for glitch in active_glitches:
		glitch.process(player, delta)

		# Check if duration-based glitch should end
		if glitch.duration > 0.0:
			glitch.current_cooldown = maxf(0.0, glitch.current_cooldown - delta)
			if glitch.current_cooldown <= 0.0:
				glitches_to_deactivate.append(glitch)

	# Deactivate expired glitches
	for glitch in glitches_to_deactivate:
		deactivate_glitch(glitch)

	# Handle input for glitch activation
	handle_glitch_input()

func _physics_process(delta: float) -> void:
	# Physics process for active glitches
	for glitch in active_glitches:
		glitch.physics_process(player, delta)

func handle_glitch_input() -> void:
	# Bind glitches to Q, E, F, Z, X, C keys
	var glitch_keys := ["glitch_1", "glitch_2", "glitch_3", "glitch_4", "glitch_5", "glitch_6"]

	for i in range(mini(available_glitches.size(), glitch_keys.size())):
		if Input.is_action_just_pressed(glitch_keys[i]):
			activate_glitch(i)

func activate_glitch(index: int) -> bool:
	if index < 0 or index >= available_glitches.size():
		return false

	var glitch := available_glitches[index]

	# Check if glitch can be used
	if not glitch.can_use():
		print("Glitch on cooldown or not ready: ", glitch.glitch_name)
		return false

	# Check energy cost
	if glitch.energy_cost > current_energy:
		print("Not enough energy for glitch: ", glitch.glitch_name)
		return false

	# If toggle glitch is already active, deactivate it
	if glitch.is_toggle and glitch.is_active:
		deactivate_glitch(glitch)
		return true

	# Consume energy
	current_energy -= glitch.energy_cost
	energy_changed.emit(current_energy, max_energy)

	# Activate glitch
	if glitch.activate(player):
		if glitch.duration > 0.0:
			active_glitches.append(glitch)
			# Store duration in cooldown temporarily for countdown
			glitch.current_cooldown = glitch.duration

		glitch_activated.emit(glitch)
		print("Activated glitch: ", glitch.glitch_name)
		return true

	return false

func deactivate_glitch(glitch: Glitch) -> void:
	if glitch in active_glitches:
		active_glitches.erase(glitch)

	glitch.deactivate(player)

	# Now start the actual cooldown
	glitch.current_cooldown = glitch.cooldown

	glitch_deactivated.emit(glitch)

func add_glitch(glitch: Glitch) -> void:
	if not available_glitches.has(glitch):
		available_glitches.append(glitch)
		print("Unlocked glitch: ", glitch.glitch_name)

func remove_glitch(glitch: Glitch) -> void:
	if glitch.is_active:
		deactivate_glitch(glitch)
	available_glitches.erase(glitch)

func has_glitch(glitch_name: String) -> bool:
	for glitch in available_glitches:
		if glitch.glitch_name == glitch_name:
			return true
	return false

func get_glitch_by_name(glitch_name: String) -> Glitch:
	for glitch in available_glitches:
		if glitch.glitch_name == glitch_name:
			return glitch
	return null

func add_energy(amount: int) -> void:
	current_energy = mini(current_energy + amount, max_energy)
	energy_changed.emit(current_energy, max_energy)

func reset_all_glitches() -> void:
	# Deactivate all active glitches
	for glitch in active_glitches.duplicate():
		deactivate_glitch(glitch)

	# Reset all glitch states
	for glitch in available_glitches:
		glitch.reset()

	# Reset energy
	current_energy = max_energy
	energy_changed.emit(current_energy, max_energy)

func get_glitch_info(index: int) -> Dictionary:
	if index < 0 or index >= available_glitches.size():
		return {}

	var glitch := available_glitches[index]
	return {
		"name": glitch.glitch_name,
		"description": glitch.description,
		"cooldown": glitch.cooldown,
		"current_cooldown": glitch.current_cooldown,
		"duration": glitch.duration,
		"energy_cost": glitch.energy_cost,
		"is_ready": glitch.is_ready(),
		"is_active": glitch.is_active,
		"uses_remaining": glitch.uses_remaining,
		"cooldown_percent": glitch.get_cooldown_percent()
	}
