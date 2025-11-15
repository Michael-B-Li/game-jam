extends Resource
class_name Glitch

## Base glitch resource that defines properties for different glitch abilities

@export var glitch_name: String = "Glitch"
@export var description: String = "A glitch effect"
@export var cooldown: float = 5.0  ## Time in seconds before glitch can be used again
@export var duration: float = 3.0  ## How long the glitch effect lasts (0 for instant)
@export var energy_cost: int = 20  ## Energy/mana cost to activate
@export var icon_color: Color = Color.MAGENTA  ## Visual indicator color
@export var is_toggle: bool = false  ## If true, can be toggled on/off
@export var max_uses: int = -1  ## -1 for unlimited uses per run

## Visual/audio feedback
@export var screen_shake: float = 0.0
@export var screen_distortion: bool = false
@export var glitch_particles: bool = true

var current_cooldown: float = 0.0
var is_active: bool = false
var uses_remaining: int = -1

func _init() -> void:
	uses_remaining = max_uses

## Called when glitch is activated
func activate(player: Node2D) -> bool:
	if not can_use():
		return false

	is_active = true
	current_cooldown = cooldown

	if uses_remaining > 0:
		uses_remaining -= 1

	return true

## Called when glitch is deactivated (for toggle glitches)
func deactivate(player: Node2D) -> void:
	is_active = false

## Called every frame while glitch is active
func process(player: Node2D, delta: float) -> void:
	pass

## Called every physics frame while glitch is active
func physics_process(player: Node2D, delta: float) -> void:
	pass

## Check if glitch can be used
func can_use() -> bool:
	if current_cooldown > 0.0:
		return false
	if uses_remaining == 0:
		return false
	if is_toggle and is_active:
		return true  # Can deactivate
	return true

## Update cooldown
func update_cooldown(delta: float) -> void:
	if current_cooldown > 0.0:
		current_cooldown -= delta
		if current_cooldown < 0.0:
			current_cooldown = 0.0

## Reset glitch state (for new run)
func reset() -> void:
	current_cooldown = 0.0
	is_active = false
	uses_remaining = max_uses

## Get cooldown percentage (0.0 to 1.0)
func get_cooldown_percent() -> float:
	if cooldown <= 0.0:
		return 1.0
	return 1.0 - (current_cooldown / cooldown)

## Check if glitch is ready
func is_ready() -> bool:
	return current_cooldown <= 0.0 and (uses_remaining != 0)
