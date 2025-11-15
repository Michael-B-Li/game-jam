extends Area2D
signal hit
@export var speed = 400
var screen_size
var gun_controller: GunController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

	# Show player for testing (comment out if using start() function)
	show()
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = false

	# Set up gun controller
	gun_controller = GunController.new()
	add_child(gun_controller)

	# Add all available guns
	gun_controller.available_guns = GunPresets.get_all_guns()
	gun_controller.current_gun = gun_controller.available_guns[0]

	# Load bullet scene - create bullet.tscn in Godot editor if not exists
	if ResourceLoader.exists("res://bullet.tscn"):
		gun_controller.bullet_scene = load("res://bullet.tscn")
	else:
		push_warning("bullet.tscn not found. Create it in Godot editor or shooting won't work.")

	# Connect gun signals for UI updates (optional)
	gun_controller.gun_switched.connect(_on_gun_switched)
	gun_controller.ammo_changed.connect(_on_ammo_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		print('Player moving right')
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		print('Player moving left')
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		print('Player moving down')
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		print('Player moving up')
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_player_body_entered(_body: Node2D):
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_gun_switched(gun: Gun) -> void:
	print("Switched to: ", gun.gun_name)

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	print("Ammo: ", current, "/", max_ammo)
