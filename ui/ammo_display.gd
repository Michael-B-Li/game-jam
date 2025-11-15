extends CanvasLayer

## Ammo display UI that shows current ammo count with icon

@onready var ammo_label: Label = $AmmoContainer/AmmoLabel
@onready var bullet_icon: TextureRect = $AmmoContainer/BulletIcon
@onready var ammo_container: HBoxContainer = $AmmoContainer

# Preload the bullet texture
const BULLET_TEXTURE = preload("res://bullet.png")

var player: Node2D = null

func _ready() -> void:
	# Apply HUD scale from settings
	_apply_hud_scale()

	# Connect to settings changes if SettingsManager exists
	if Engine.has_singleton("SettingsManager"):
		var settings = Engine.get_singleton("SettingsManager")
		if settings.has_signal("hud_scale_changed"):
			settings.hud_scale_changed.connect(_on_hud_scale_changed)

	# Find player - wait a bit for player to initialize
	await get_tree().process_frame
	await get_tree().process_frame  # Wait extra frame for gun controller to be set up
	player = get_tree().get_first_node_in_group("player")

	if not player:
		push_warning("AmmoDisplay: Player not found in 'player' group")
		return

	# Try to access gun_controller - it should exist if player script ran
	if player.has_method("get") and player.get("gun_controller"):
		var gun_ctrl = player.get("gun_controller")
		if gun_ctrl:
			_setup_gun_controller(gun_ctrl)
	else:
		# Fallback: try direct access
		var gun_ctrl = player.gun_controller if "gun_controller" in player else null
		if gun_ctrl:
			_setup_gun_controller(gun_ctrl)
		else:
			push_warning("AmmoDisplay: gun_controller not found on player")

func _apply_hud_scale() -> void:
	# Get HUD scale from Engine metadata (set by settings)
	var scale = 1.0
	if Engine.has_meta("hud_scale"):
		scale = Engine.get_meta("hud_scale")

	# Apply scale to the ammo container
	ammo_container.scale = Vector2(scale, scale)

func _on_hud_scale_changed(new_scale: float) -> void:
	ammo_container.scale = Vector2(new_scale, new_scale)

func _setup_gun_controller(gun_ctrl) -> void:
	# Connect to gun controller signals
	gun_ctrl.ammo_changed.connect(_on_ammo_changed)
	gun_ctrl.gun_switched.connect(_on_gun_switched)

	# Set initial ammo display
	if gun_ctrl.current_gun:
		var current_ammo = gun_ctrl.gun_ammo.get(gun_ctrl.current_gun, -1)
		if current_ammo >= 0:
			update_ammo_display(current_ammo, gun_ctrl.current_gun.ammo_capacity)
		else:
			ammo_label.text = "∞"  # Infinite ammo

	# Load bullet texture
	if bullet_icon:
		bullet_icon.texture = BULLET_TEXTURE

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	update_ammo_display(current, max_ammo)

func _on_gun_switched(gun) -> void:
	if player:
		var gun_ctrl = player.gun_controller if "gun_controller" in player else null
		if gun_ctrl:
			var current_ammo = gun_ctrl.gun_ammo.get(gun, -1)
			if current_ammo >= 0:
				update_ammo_display(current_ammo, gun.ammo_capacity)
			else:
				ammo_label.text = "∞"

func update_ammo_display(current: int, max_ammo: int) -> void:
	if not ammo_label:
		return
	ammo_label.text = str(current) + " / " + str(max_ammo)

	# Change color based on ammo level
	if current == 0:
		ammo_label.modulate = Color.RED
	elif current <= max_ammo * 0.3:
		ammo_label.modulate = Color.YELLOW
	else:
		ammo_label.modulate = Color.WHITE
