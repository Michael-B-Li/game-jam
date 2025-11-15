extends RigidBody2D
class_name Enemy

signal defeated(enemy: Enemy)

@export var speed: float = 150.0
@export var max_health: int = 1
@export var acceleration: float = 6.0

var _health: int
var _active := true
var facing: Vector2 = Vector2.RIGHT

func _ready() -> void:
	_health = max_health
	_on_spawned()

func _physics_process(delta: float) -> void:
	if not _active:
		linear_velocity = Vector2.ZERO
		return
	var desired_velocity := _desired_velocity(delta)
	if desired_velocity.length_squared() > 0.0001:
		facing = desired_velocity.normalized()
	var limited_velocity := desired_velocity.limit_length(speed)
	var lerp_weight := clampf(acceleration * delta, 0.0, 1.0)
	linear_velocity = linear_velocity.lerp(limited_velocity, lerp_weight)
	_process_enemy(delta)

func _desired_velocity(_delta: float) -> Vector2:
	return Vector2.ZERO

func _process_enemy(_delta: float) -> void:
	pass

func take_damage(amount: int = 1) -> void:
	if not _active:
		return
	_health -= amount
	if _health <= 0:
		die()

func die() -> void:
	if not _active:
		return
	_active = false
	hide()
	defeated.emit(self)
	queue_free()

func is_dead() -> bool:
	return not _active

func reset(position: Vector2) -> void:
	global_position = position
	_health = max_health
	_active = true
	linear_velocity = Vector2.ZERO
	show()
	_on_spawned()

func set_active(value: bool) -> void:
	_active = value
	if not value:
		linear_velocity = Vector2.ZERO

func _on_spawned() -> void:
	pass
