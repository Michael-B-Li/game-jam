extends Node
class_name GunPresets

## Preset gun configurations for easy access throughout the game

static func get_pistol() -> Gun:
	var gun := Gun.new()
	gun.gun_name = "Pistol"
	gun.fire_rate = 0.2
	gun.bullet_speed = 800.0
	gun.damage = 10
	gun.bullet_count = 1
	gun.spread_angle = 2.0
	gun.ammo_capacity = 12
	gun.reload_time = 1.2
	gun.automatic = false
	gun.bullet_color = Color.YELLOW
	return gun

static func get_rifle() -> Gun:
	var gun := Gun.new()
	gun.gun_name = "Rifle"
	gun.fire_rate = 0.15
	gun.bullet_speed = 1000
	gun.damage = 15
	gun.bullet_count = 1
	gun.spread_angle = 10
	gun.ammo_capacity = 30
	gun.reload_time = 3.0
	gun.automatic = true
	gun.bullet_color = Color.ORANGE
	return gun

static func get_revolver() -> Gun:
	var gun := Gun.new()
	gun.gun_name = "Revolver"
	gun.fire_rate = 0.8
	gun.bullet_speed = 1750
	gun.damage = 75
	gun.bullet_count = 1
	gun.spread_angle = 0.5
	gun.ammo_capacity = 6
	gun.reload_time = 4
	gun.automatic = false
	gun.bullet_color = Color.SILVER
	return gun

static func get_shotgun() -> Gun:
	var gun := Gun.new()
	gun.gun_name = "Shotgun"
	gun.fire_rate = 0.8
	gun.bullet_speed = 1750
	gun.damage = 12
	gun.bullet_count = 8
	gun.spread_angle = 45
	gun.ammo_capacity = 4
	gun.reload_time = 2.0
	gun.automatic = false
	gun.bullet_color = Color.ORANGE_RED
	return gun

static func get_all_guns() -> Array[Gun]:
	return [
		get_pistol(),
		get_rifle(),
		get_revolver(),
		get_shotgun()
	]
