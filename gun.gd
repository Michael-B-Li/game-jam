extends Resource
class_name Gun

## Base gun resource that defines properties for different weapon types

@export var gun_name: String = "Gun"
@export var fire_rate: float = 0.5  ## Time in seconds between shots
@export var bullet_speed: float = 500.0
@export var damage: int = 1
@export var bullet_count: int = 1  ## For shotgun-style spread
@export var spread_angle: float = 0.0  ## Angle in degrees for bullet spread
@export var recoil: float = 0.0  ## Visual/mechanical recoil amount
@export var ammo_capacity: int = -1  ## -1 for infinite ammo
@export var reload_time: float = 1.0
@export var automatic: bool = false  ## If true, holds to shoot; if false, click per shot
@export var bullet_color: Color = Color.WHITE
@export var muzzle_flash_enabled: bool = true

func _init(
	p_name: String = "Gun",
	p_fire_rate: float = 0.5,
	p_bullet_speed: float = 500.0,
	p_damage: int = 1,
	p_bullet_count: int = 1,
	p_spread_angle: float = 0.0,
	p_automatic: bool = false
) -> void:
	gun_name = p_name
	fire_rate = p_fire_rate
	bullet_speed = p_bullet_speed
	damage = p_damage
	bullet_count = p_bullet_count
	spread_angle = p_spread_angle
	automatic = p_automatic
