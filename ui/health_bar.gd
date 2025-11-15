extends CanvasLayer

## Health bar UI that shows current player health

@onready var health_label: Label = $HealthContainer/HealthLabel
@onready var progress_bar: ProgressBar = $HealthContainer/ProgressBar
@onready var fill: ColorRect = $HealthContainer/ProgressBar/Fill
@onready var health_container: VBoxContainer = $HealthContainer

var player: Node2D = null
var max_health: float = 100.0

func _ready() -> void:
	# Apply HUD scale from settings
	_apply_hud_scale()

	# Connect to settings changes if SettingsManager exists
	if Engine.has_singleton("SettingsManager"):
		var settings = Engine.get_singleton("SettingsManager")
		if settings.has_signal("hud_scale_changed"):
			settings.hud_scale_changed.connect(_on_hud_scale_changed)
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if not player:
		push_warning("HealthBar: Player not found in 'player' group")
		return

	# Get max health from player
	if "max_health" in player:
		max_health = player.max_health
	elif "health" in player:
		max_health = player.health

	progress_bar.max_value = max_health

	# Connect to player health changes if available
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)

	# Set initial health
	_update_health_display()

func _apply_hud_scale() -> void:
	# Get HUD scale from Engine metadata (set by settings)
	var scale = 1.0
	if Engine.has_meta("hud_scale"):
		scale = Engine.get_meta("hud_scale")

	# Apply scale to the health container
	health_container.scale = Vector2(scale, scale)

func _on_hud_scale_changed(new_scale: float) -> void:
	health_container.scale = Vector2(new_scale, new_scale)

func _process(_delta: float) -> void:
	# Update health display each frame (fallback if no signal)
	if player and not player.has_signal("health_changed"):
		_update_health_display()

func _update_health_display() -> void:
	if not player:
		return

	var current_health = 0.0
	if "health" in player:
		current_health = player.health

	progress_bar.value = current_health

	# Update fill width based on health percentage
	var health_percent = current_health / max_health
	fill.scale.x = health_percent

	# Change color based on health level
	if health_percent <= 0.25:
		fill.color = Color(0.6, 0.05, 0.05, 1)  # Dark red when low
	elif health_percent <= 0.5:
		fill.color = Color(0.9, 0.3, 0.1, 1)  # Orange-red
	else:
		fill.color = Color(0.9, 0.1, 0.1, 1)  # Bright red

func _on_health_changed(new_health: float) -> void:
	_update_health_display()
