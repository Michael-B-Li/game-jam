# We now extend CharacterBody2D for physics and collision
extends CharacterBody2D

# Preload glitch system
const Glitch = preload("res://glitches/glitch.gd")
const GlitchController = preload("res://glitches/glitch_controller.gd")
const GlitchTypes = preload("res://glitches/glitch_types.gd")

signal hit

signal health_changed(new_health: float)
@export var speed = 400
@export var max_health: float = 100.0
var health: float = 100.0

var screen_size
var last_dir = Vector2.DOWN
var gun_controller: GunController
var glitch_controller: GlitchController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player _ready() called")
	screen_size = get_viewport_rect().size
	print("Screen size: ", screen_size)

	# Add to player group for UI and other systems to find
	add_to_group("player")

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
	if gun_controller.available_guns.size() > 0:
		gun_controller.current_gun = gun_controller.available_guns[0]

		# Initialize ammo after guns are set (in case _ready() already ran)
		gun_controller.initialize_ammo()

		print("Gun controller setup complete. Current gun: ", gun_controller.current_gun.gun_name)
	else:
		push_error("No guns available! GunPresets.get_all_guns() returned empty array.")

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

	# Initialize health
	health = max_health
	health_changed.emit(health)


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

	var dir = input_vector.normalized()
	
	# Determine current movement characteristics
	var is_moving = dir.length_squared() > 0
	
	# Only flip the sprite when moving

	if is_moving:
		# --- MOVEMENT LOGIC ---
		last_dir = dir # Store the non-zero direction
		velocity = dir * speed
		
		$AnimatedSprite2D.play()
		
		$AnimatedSprite2D.flip_h = dir.x < 0
		
		# Determine animation based on direction
		if dir.y < 0:
			# Moving Up/Backward
			if dir.x != 0:
				$AnimatedSprite2D.animation = "w_bd"
			else:
				$AnimatedSprite2D.animation = "w_b"
		elif dir.y > 0:
			# Moving Down/Forward
			if dir.x != 0:
				$AnimatedSprite2D.animation = "w_fd"
			else:
				$AnimatedSprite2D.animation = "w_f"
		else:
			# Pure Sideways Movement (dir.y == 0)
			$AnimatedSprite2D.animation = "w_fd"
	else:
		# --- IDLE LOGIC ---
		$AnimatedSprite2D.play()
		# Set flip based on the last horizontal movement
		$AnimatedSprite2D.flip_h = last_dir.x < 0
		velocity = Vector2.ZERO
		
		# Idle animation selection based on last_dir
		if last_dir.y < 0:
			# Last movement was Up/Backward
			if last_dir.x != 0:
				# Stopped from diagonal up
				$AnimatedSprite2D.animation = "i_bd"
			else:
				# Stopped from moving purely up
				$AnimatedSprite2D.animation = "i_b"
		else:
			# Last movement was Down/Forward or Pure Sideways (y >= 0)
			if last_dir.x != 0:
				# Stopped from diagonal down or pure side
				$AnimatedSprite2D.animation = "i_fd"
			else:
				# Stopped from moving purely down/forward
				$AnimatedSprite2D.animation = "i_f"

	# THIS IS THE FIX:
	# Use move_and_slide() to handle movement and collisions.
	move_and_slide()

	# Test key for taking damage
	if Input.is_action_just_pressed("ui_page_down"):
		take_damage(10)

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
	print("GLITCH DEACTIVATED: ", glitch.glitch_.glitch_name)

func _on_energy_changed(current: int, max_energy: int) -> void:
	print("Energy: ", current, "/", max_energy)

func take_damage(damage: float) -> void:
	health = max(0, health - damage)
	health_changed.emit(health)
	print("Player took damage! Health: ", health, "/", max_health)

	if health <= 0:
		die()

func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health)
	print("Player healed! Health: ", health, "/", max_health)

func die() -> void:
	print("Player died!")
	hide()
	hit.emit()
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
