extends Area2D
class_name Bullet

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1
var lifetime: float = 5.0  ## Bullet despawns after this many seconds

func _ready() -> void:
	# Set up collision detection
	body_entered.connect(_on_body_entered)

	# Auto-destroy after lifetime expires
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	position += velocity * delta

func initialize(direction: Vector2, speed: float, bullet_damage: int, color: Color = Color.WHITE) -> void:
	velocity = direction.normalized() * speed
	damage = bullet_damage

	# Set bullet visual color if it has a modulate-able sprite/shape
	modulate = color

func _on_body_entered(body: Node2D) -> void:
	# Handle collision with enemies or other objects
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# Destroy bullet on impact
	queue_free()
