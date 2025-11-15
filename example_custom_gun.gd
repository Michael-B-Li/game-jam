extends Node

## Example script showing how to create and add a custom gun
## This can be used as a reference or attached to a node to add guns at runtime

# Reference to the player's gun controller
@onready var player_gun_controller: GunController = get_node("/root/Main/Player/GunController")

func _ready() -> void:
	# Example 1: Create a flamethrower
	add_flamethrower()

	# Example 2: Create a laser gun
	add_laser_gun()

	# Example 3: Create a rocket launcher
	add_rocket_launcher()

func add_flamethrower() -> void:
	var flamethrower := Gun.new()
	flamethrower.gun_name = "Flamethrower"
	flamethrower.fire_rate = 0.05  # Very fast - 20 shots per second
	flamethrower.bullet_speed = 250.0  # Slow moving flames
	flamethrower.damage = 2  # Low damage per flame
	flamethrower.bullet_count = 3  # Multiple flames per shot
	flamethrower.spread_angle = 25.0  # Wide cone of fire
	flamethrower.ammo_capacity = 200  # Lots of ammo
	flamethrower.reload_time = 3.0
	flamethrower.automatic = true  # Hold to spray
	flamethrower.bullet_color = Color.ORANGE_RED

	player_gun_controller.add_gun(flamethrower)
	print("Added Flamethrower!")

func add_laser_gun() -> void:
	var laser := Gun.new()
	laser.gun_name = "Laser Rifle"
	laser.fire_rate = 0.15  # Fast but not instant
	laser.bullet_speed = 2000.0  # Very fast projectiles
	laser.damage = 25  # High damage
	laser.bullet_count = 1
	laser.spread_angle = 0.0  # Perfect accuracy
	laser.ammo_capacity = -1  # Infinite ammo (energy weapon)
	laser.automatic = true
	laser.bullet_color = Color.CYAN

	player_gun_controller.add_gun(laser)
	print("Added Laser Rifle!")

func add_rocket_launcher() -> void:
	var rocket := Gun.new()
	rocket.gun_name = "Rocket Launcher"
	rocket.fire_rate = 2.0  # Slow fire rate
	rocket.bullet_speed = 400.0  # Medium speed
	rocket.damage = 100  # Very high damage
	rocket.bullet_count = 1
	rocket.spread_angle = 0.0  # Accurate
	rocket.ammo_capacity = 8  # Limited ammo
	rocket.reload_time = 4.0  # Long reload
	rocket.automatic = false  # Manual fire
	rocket.bullet_color = Color.RED

	player_gun_controller.add_gun(rocket)
	print("Added Rocket Launcher!")

func add_freeze_ray() -> void:
	var freeze := Gun.new()
	freeze.gun_name = "Freeze Ray"
	freeze.fire_rate = 0.1
	freeze.bullet_speed = 300.0
	freeze.damage = 5  # Low damage but could slow enemies
	freeze.bullet_count = 1
	freeze.spread_angle = 5.0
	freeze.ammo_capacity = 50
	freeze.reload_time = 2.0
	freeze.automatic = true
	freeze.bullet_color = Color.LIGHT_BLUE

	player_gun_controller.add_gun(freeze)
	print("Added Freeze Ray!")

func add_plasma_cannon() -> void:
	var plasma := Gun.new()
	plasma.gun_name = "Plasma Cannon"
	plasma.fire_rate = 0.4
	plasma.bullet_speed = 800.0
	plasma.damage = 35
	plasma.bullet_count = 1
	plasma.spread_angle = 1.0  # Slight spread
	plasma.ammo_capacity = 20
	plasma.reload_time = 2.5
	plasma.automatic = false
	plasma.bullet_color = Color.PURPLE

	player_gun_controller.add_gun(plasma)
	print("Added Plasma Cannon!")

func add_scatter_gun() -> void:
	var scatter := Gun.new()
	scatter.gun_name = "Scatter Gun"
	scatter.fire_rate = 0.5
	scatter.bullet_speed = 500.0
	scatter.damage = 8
	scatter.bullet_count = 5  # 5 projectiles
	scatter.spread_angle = 15.0  # Medium spread
	scatter.ammo_capacity = 25
	scatter.reload_time = 2.0
	scatter.automatic = false
	scatter.bullet_color = Color.YELLOW

	player_gun_controller.add_gun(scatter)
	print("Added Scatter Gun!")

## Alternative: Load gun from a .tres resource file
func load_gun_from_resource() -> void:
	# If you save a Gun as a resource in Godot editor:
	var gun: Gun = load("res://guns/my_custom_gun.tres")
	player_gun_controller.add_gun(gun)

## Add gun when player picks up an item
func _on_pickup_collected() -> void:
	# Example: Give player a new gun when they collect a pickup
	add_plasma_cannon()
	# Switch to the newly added gun
	player_gun_controller.switch_gun(player_gun_controller.available_guns.size() - 1)
