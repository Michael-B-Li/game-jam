extends CharacterBody2D

## Example enemy script demonstrating difficulty settings integration
## This shows how to use SettingsManager to scale enemy stats based on difficulty
##
## NOTE: This is an EXAMPLE/REFERENCE file. SettingsManager errors are expected
## until the project is fully loaded in Godot with the autoload configured.

# Base stats (set these in the editor or code)
@export var base_health: float = 100.0
@export var base_damage: float = 10.0
@export var base_speed: float = 150.0

# Actual stats (modified by difficulty)
var current_health: float
var max_health: float
var damage: float
var speed: float

func _ready():
	# Initialize stats based on current difficulty
	apply_difficulty_settings()

	# Listen for difficulty changes (optional - allows changing difficulty mid-game)
	if SettingsManager:
		SettingsManager.difficulty_changed.connect(_on_difficulty_changed)

func apply_difficulty_settings():
	"""Apply difficulty multiplier to all enemy stats"""
	var multiplier = SettingsManager.get_difficulty_multiplier() if SettingsManager else 1.0

	# Scale stats based on difficulty
	max_health = base_health * multiplier
	current_health = max_health
	damage = base_damage * multiplier
	speed = base_speed * multiplier

	print("Enemy initialized with difficulty: ", SettingsManager.get_difficulty() if SettingsManager else "Normal")
	print("  Health: ", max_health)
	print("  Damage: ", damage)
	print("  Speed: ", speed)

func _on_difficulty_changed(new_difficulty: String):
	"""Called when difficulty changes (optional feature)"""
	print("Difficulty changed to: ", new_difficulty)

	# Option 1: Update existing enemy stats proportionally
	var old_health_percent = current_health / max_health
	apply_difficulty_settings()
	current_health = max_health * old_health_percent

	# Option 2: Only apply to new enemies (comment out above, don't reapply)
	# This is better for gameplay - existing enemies keep their original stats

func take_damage(amount: float):
	"""Example damage function"""
	current_health -= amount

	if current_health <= 0:
		die()

func attack_player(player):
	"""Example attack function"""
	if player.has_method("take_damage"):
		# Deal damage based on difficulty-scaled damage value
		player.take_damage(damage)

func die():
	"""Handle enemy death"""
	print("Enemy defeated!")
	queue_free()

func _physics_process(_delta):
	# Example: Chase player with difficulty-scaled speed
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

## DIFFICULTY SCALING REFERENCE:
##
## Easy (0.75x):
##   - Enemy has 75 health instead of 100
##   - Enemy deals 7.5 damage instead of 10
##   - Enemy moves at 112.5 speed instead of 150
##
## Normal (1.0x):
##   - Enemy has 100 health
##   - Enemy deals 10 damage
##   - Enemy moves at 150 speed
##
## Hard (1.5x):
##   - Enemy has 150 health instead of 100
##   - Enemy deals 15 damage instead of 10
##   - Enemy moves at 225 speed instead of 150
