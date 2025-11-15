extends CanvasLayer

## Ammo display UI that shows current ammo count with icon

@onready var ammo_label: Label = $AmmoContainer/AmmoLabel
@onready var bullet_icon: TextureRect = $AmmoContainer/BulletIcon

# Preload the bullet texture
const BULLET_TEXTURE = preload("res://bullet.png")

var player: Node2D = null

func _ready() -> void:
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if player and player.has("gun_controller"):
		# Connect to gun controller signals
		player.gun_controller.ammo_changed.connect(_on_ammo_changed)
		player.gun_controller.gun_switched.connect(_on_gun_switched)

		# Set initial ammo display
		if player.gun_controller.current_gun:
			var current_ammo = player.gun_controller.gun_ammo.get(player.gun_controller.current_gun, -1)
			if current_ammo >= 0:
				update_ammo_display(current_ammo, player.gun_controller.current_gun.ammo_capacity)
			else:
				ammo_label.text = "∞"  # Infinite ammo

		# Load bullet texture
		if bullet_icon:
			bullet_icon.texture = BULLET_TEXTURE

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	update_ammo_display(current, max_ammo)

func _on_gun_switched(gun) -> void:
	if player and player.has("gun_controller"):
		var current_ammo = player.gun_controller.gun_ammo.get(gun, -1)
		if current_ammo >= 0:
			update_ammo_display(current_ammo, gun.ammo_capacity)
		else:
			ammo_label.text = "∞"

func update_ammo_display(current: int, max_ammo: int) -> void:
	ammo_label.text = str(current) + " / " + str(max_ammo)

	# Change color based on ammo level
	if current == 0:
		ammo_label.modulate = Color.RED
	elif current <= max_ammo * 0.3:
		ammo_label.modulate = Color.YELLOW
	else:
		ammo_label.modulate = Color.WHITE
