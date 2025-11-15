extends Node2D
class_name GunController

## Handles shooting mechanics and gun switching for the player

signal gun_switched(gun: Gun)
signal ammo_changed(current: int, max: int)
signal reloading(time: float)

@export var bullet_scene: PackedScene
@export var current_gun: Gun
@export var available_guns: Array[Gun] = []

var gun_ammo: Dictionary = {}  ## Tracks ammo per gun
var can_shoot: bool = true
var is_reloading: bool = false
var shoot_timer: float = 0.0

func _ready() -> void:
	# Initialize ammo for all guns
	initialize_ammo()

func initialize_ammo() -> void:
	# Initialize ammo for all guns
	for gun in available_guns:
		if not gun_ammo.has(gun):
			if gun.ammo_capacity > 0:
				gun_ammo[gun] = gun.ammo_capacity
			else:
				gun_ammo[gun] = -1

	# Set current gun ammo
	if current_gun:
		if not gun_ammo.has(current_gun):
			if current_gun.ammo_capacity > 0:
				gun_ammo[current_gun] = current_gun.ammo_capacity
			else:
				gun_ammo[current_gun] = -1

func _process(delta: float) -> void:
	if not current_gun:
		return

	# Update shoot timer
	if shoot_timer > 0:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true

	# Handle shooting input
	var shoot_input: bool = false
	if current_gun.automatic:
		shoot_input = Input.is_action_pressed("shoot")
	else:
		shoot_input = Input.is_action_just_pressed("shoot")

	if shoot_input and can_shoot and not is_reloading:
		shoot()

	# Handle reload input
	if Input.is_action_just_pressed("reload") and not is_reloading:
		var current_ammo = gun_ammo.get(current_gun, -1)
		if current_gun.ammo_capacity > 0 and current_ammo < current_gun.ammo_capacity:
			reload()

	# Handle gun switching (1-9 keys or mouse wheel)
	for i in range(min(available_guns.size(), 9)):
		if Input.is_action_just_pressed("weapon_" + str(i + 1)):
			switch_gun(i)

func shoot() -> void:
	if not bullet_scene:
		push_warning("No bullet scene assigned to GunController")
		print("ERROR: No bullet scene!")
		return

	# Check ammo
	if current_gun.ammo_capacity > 0:
		var current_ammo = gun_ammo.get(current_gun, 0)
		if current_ammo <= 0:
			# Out of ammo - can't shoot
			print("Out of ammo! Current ammo: ", current_ammo)
			return
		gun_ammo[current_gun] = current_ammo - 1
		ammo_changed.emit(gun_ammo[current_gun], current_gun.ammo_capacity)

		# Auto-reload when ammo reaches 0
		if gun_ammo[current_gun] == 0:
			print("Magazine empty - auto-reloading!")
			reload()

	# Get shooting direction (towards mouse)
	var mouse_pos: Vector2 = get_global_mouse_position()
	var shoot_direction: Vector2 = (mouse_pos - global_position).normalized()
	
	print("Shooting! Mouse: ", mouse_pos, " Player: ", global_position, " Direction: ", shoot_direction)

	# Spawn bullets based on bullet_count
	for i in range(current_gun.bullet_count):
		var bullet: Bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position
		print("Spawned bullet at: ", bullet.global_position)

		# Calculate spread
		var angle_offset: float = 0.0
		if current_gun.bullet_count > 1:
			# Distribute bullets evenly across spread angle
			var step: float = current_gun.spread_angle / (current_gun.bullet_count - 1) if current_gun.bullet_count > 1 else 0.0
			angle_offset = -current_gun.spread_angle / 2.0 + step * i
		elif current_gun.spread_angle > 0:
			# Random spread for single bullet
			angle_offset = randf_range(-current_gun.spread_angle / 2.0, current_gun.spread_angle / 2.0)

		var spread_direction: Vector2 = shoot_direction.rotated(deg_to_rad(angle_offset))
		bullet.initialize(spread_direction, current_gun.bullet_speed, current_gun.damage, current_gun.bullet_color)

	# Apply cooldown
	can_shoot = false
	shoot_timer = current_gun.fire_rate

func reload() -> void:
	if is_reloading:
		return

	if current_gun.ammo_capacity <= 0:
		return  # Infinite ammo guns don't reload

	is_reloading = true
	print('Reloading')
	can_shoot = false
	reloading.emit(current_gun.reload_time)

	await get_tree().create_timer(current_gun.reload_time).timeout

	gun_ammo[current_gun] = current_gun.ammo_capacity
	is_reloading = false
	can_shoot = true
	ammo_changed.emit(gun_ammo[current_gun], current_gun.ammo_capacity)

func switch_gun(index: int) -> void:
	if index < 0 or index >= available_guns.size():
		return

	current_gun = available_guns[index]

	# Initialize ammo for new gun if not tracked yet
	if not gun_ammo.has(current_gun):
		if current_gun.ammo_capacity > 0:
			gun_ammo[current_gun] = current_gun.ammo_capacity
		else:
			gun_ammo[current_gun] = -1

	# Emit current ammo for this gun
	var current_ammo = gun_ammo.get(current_gun, -1)
	if current_ammo >= 0:
		ammo_changed.emit(current_ammo, current_gun.ammo_capacity)

	# Reset state
	is_reloading = false
	can_shoot = true
	shoot_timer = 0.0

	gun_switched.emit(current_gun)

func add_gun(gun: Gun) -> void:
	if not available_guns.has(gun):
		available_guns.append(gun)

func get_current_gun_name() -> String:
	return current_gun.gun_name if current_gun else "No Gun"
