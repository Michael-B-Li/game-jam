extends Enemy

@export var direction_change_interval: float = 1.5

var _direction := Vector2.ZERO
var _time_until_flip := 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	super._ready()

func _on_spawned() -> void:
	_direction = Vector2.ZERO
	_time_until_flip = 0.0

func _desired_velocity(delta: float) -> Vector2:
	_time_until_flip -= delta
	if _time_until_flip <= 0.0 or _direction == Vector2.ZERO:
		_direction = _pick_direction()
		_time_until_flip = max(direction_change_interval, 0.1)
	return _direction * speed

func _pick_direction() -> Vector2:
	var dir := Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	if dir.length_squared() == 0.0:
		dir = Vector2.LEFT
	return dir.normalized()
