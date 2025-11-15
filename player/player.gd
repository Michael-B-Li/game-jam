# We now extend CharacterBody2D for physics and collision
extends CharacterBody2D

# Preload glitch system
const Glitch = preload("res://glitches/glitch.gd")
const GlitchController = preload("res://glitches/glitch_controller.gd")

signal hit
@export var speed = 400
var screen_size
var gun_controller: GunController
var glitch_controller: GlitchController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

	# We let the 'start()' function handle this
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true

	# Set up gun controller
	gun_controller = GunController.new()
	add_child(gun_controller)

	# Load bullet scene - create bullet.tscn in Godot editor if not exists
	if ResourceLoader.exists("res://guns/bullet.tscn"):
		gun_controller.bullet_scene = load("res://guns/bullet.tscn")
		print("Bullet scene loaded successfully")
	else:
		push_warning("bullet.tscn not found. Create it in Godot editor or shooting won't work.")
		print("ERROR: bullet.tscn not found!")

	# Add all available guns
	gun_controller.available_guns = GunPresets.get_all_guns()
	gun_controller.current_gun = gun_controller.available_guns[0]
	
	# Initialize ammo after guns are set (in case _ready() already ran)
	gun_controller.initialize_ammo()
	
	print("Gun controller setup complete. Current gun: ", gun_controller.current_gun.gun_name)

	# Connect gun signals for UI updates (optional)
	gun_controller.gun_switched.connect(_on_gun_switched)
	gun_controller.ammo_changed.connect(_on_ammo_changed)

	# Set up glitch controller
	glitch_controller = GlitchController.new()
	add_child(glitch_controller)

	# Add starter glitches
	glitch_controller.available_glitches = GlitchTypes.get_basic_glitches()

	# Connect glitch signals for UI updates (optional)
	glitch_controller.glitch_activated.connect(_on_glitch_activated)
	glitch_controller.glitch_deactivated.connect(_on_glitch_deactivated)
	glitch_controller.energy_changed.connect(_on_energy_changed)


# We use _physics_process for physics-based movement
func _physics_process(delta):
	# Get input vector
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1

	# Set velocity
	if input_vector.length() > 0:
		velocity = input_vector.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		velocity = Vector2.ZERO # Stop moving
		$AnimatedSprite2D.stop()
	
	# This function moves the player and handles collisions automatically
	move_and_slide()
	
	# We remove the position.clamp() line so you can move around the map
	
	# Animation logic
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

#
# This function was the problem! It was part of Area2D and was
# being triggered by the walls, causing the player to hide.
# A CharacterBody2D doesn't use this. If you want to detect
# enemies, you'll add a *separate* Area2D as a child.
#
# func _on_player_body_entered(_body: Node2D):
# 	hide()
# 	hit.emit()
# 	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# --- These signal functions are all fine ---

func _on_gun_switched(gun: Gun) -> void:
	print("Switched to: ", gun.gun_name)

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	print("Ammo: ", current, "/", max_ammo)

func _on_glitch_activated(glitch: Glitch) -> void:
	print("GLITCH ACTIVATED: ", glitch.glitch_name)

func _on_glitch_deactivated(glitch: Glitch) -> void:
	print("GLITCH DEACTIVATED: ", glitch.glitch_name)

func _on_energy_changed(current: int, max_energy: int) -> void:
	print("Energy: ", current, "/", max_energy)
