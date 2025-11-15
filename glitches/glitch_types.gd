class_name GlitchTypes

## Specific glitch implementations for the roguelike

const Glitch = preload("res://glitches/glitch.gd")

## NOCLIP - Walk through walls
class NoclipGlitch extends Glitch:
	var original_collision_layer: int = 0
	var original_collision_mask: int = 0

	func _init() -> void:
		glitch_name = "Noclip"
		description = "Phase through walls and obstacles"
		cooldown = 8.0
		duration = 4.0
		energy_cost = 30
		icon_color = Color(0.5, 0.5, 1.0, 0.5)  # Translucent blue
		is_toggle = false
		screen_distortion = true
		glitch_particles = true

	func activate(player: Node2D) -> bool:
		if not super.activate(player):
			return false

		# Store original collision settings
		if player is Area2D or player is CharacterBody2D or player is RigidBody2D:
			original_collision_layer = player.collision_layer
			original_collision_mask = player.collision_mask
			# Disable collisions with walls (assuming walls are on layer 1)
			player.collision_mask = 0
			player.modulate = Color(0.5, 0.5, 1.0, 0.5)  # Make player translucent

		print("GLITCH: Noclip activated - Phasing through walls!")
		return true

	func deactivate(player: Node2D) -> void:
		super.deactivate(player)

		# Restore collision settings
		if player is Area2D or player is CharacterBody2D or player is RigidBody2D:
			player.collision_layer = original_collision_layer
			player.collision_mask = original_collision_mask
			player.modulate = Color.WHITE

		print("GLITCH: Noclip deactivated")

## DUPLICATION - Duplicate items, bullets, or even yourself
class DuplicationGlitch extends Glitch:
	@export var duplicate_range: float = 100.0

	func _init() -> void:
		glitch_name = "Duplication"
		description = "Duplicate nearby objects or bullets"
		cooldown = 6.0
		duration = 0.0  # Instant effect
		energy_cost = 25
		icon_color = Color.GREEN
		screen_shake = 5.0
		glitch_particles = true

	func activate(player: Node2D) -> bool:
		if not super.activate(player):
			return false

		# Find bullets in range and duplicate them
		var bullets = player.get_tree().get_nodes_in_group("bullets")
		var duplicated_count: int = 0

		for bullet in bullets:
			if bullet is Node2D and player.global_position.distance_to(bullet.global_position) < duplicate_range:
				# Create a duplicate
				var bullet_copy = bullet.duplicate()
				bullet.get_parent().add_child(bullet_copy)
				bullet_copy.global_position = bullet.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
				# Add slight random velocity change
				if bullet_copy.has("velocity"):
					bullet_copy.velocity = bullet_copy.velocity.rotated(randf_range(-0.2, 0.2))
				duplicated_count += 1

		print("GLITCH: Duplicated ", duplicated_count, " objects!")
		is_active = false
		return true

## TIME DESYNC - Slow down time for enemies, speed up player
class TimeDesyncGlitch extends Glitch:
	var time_scale: float = 0.3  # Enemies move at 30% speed
	var player_speed_mult: float = 1.5  # Player moves 50% faster
	var affected_enemies: Array = []
	var original_player_speed: float = 0.0

	func _init() -> void:
		glitch_name = "Time Desync"
		description = "Slow down time for enemies"
		cooldown = 12.0
		duration = 5.0
		energy_cost = 40
		icon_color = Color.CYAN
		screen_distortion = true
		glitch_particles = true

	func activate(player: Node2D) -> bool:
		if not super.activate(player):
			return false

		# Store and boost player speed
		if player.has("speed"):
			original_player_speed = player.speed
			player.speed *= player_speed_mult

		# Slow down all enemies
		affected_enemies.clear()
		var enemies = player.get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if enemy.has("speed"):
				affected_enemies.append(enemy)
				enemy.speed *= time_scale

		print("GLITCH: Time Desync activated - ", affected_enemies.size(), " enemies slowed!")
		return true

	func deactivate(player: Node2D) -> void:
		super.deactivate(player)

		# Restore player speed
		if player.has("speed") and original_player_speed > 0:
			player.speed = original_player_speed

		# Restore enemy speeds
		for enemy in affected_enemies:
			if is_instance_valid(enemy) and enemy.has("speed"):
				enemy.speed /= time_scale

		affected_enemies.clear()
		print("GLITCH: Time Desync ended")

## BLINK - Teleport short distance towards cursor
class BlinkGlitch extends Glitch:
	var blink_distance: float = 200.0

	func _init() -> void:
		glitch_name = "Blink"
		description = "Teleport towards cursor"
		cooldown = 3.0
		duration = 0.0  # Instant
		energy_cost = 15
		icon_color = Color.PURPLE
		screen_shake = 3.0
		glitch_particles = true

	func activate(player: Node2D) -> bool:
		if not super.activate(player):
			return false

		# Get mouse position
		var mouse_pos: Vector2 = player.get_global_mouse_position()
		var direction: Vector2 = (mouse_pos - player.global_position).normalized()
		var target_pos: Vector2 = player.global_position + direction * blink_distance

		# Create visual effect at old position
		create_blink_effect(player.global_position)

		# Teleport player
		player.global_position = target_pos

		# Create visual effect at new position
		create_blink_effect(player.global_position)

		print("GLITCH: Blinked!")
		is_active = false
		return true

	func create_blink_effect(_pos: Vector2) -> void:
		# TODO: Add particle effect or visual feedback
		pass

## BUFFER OVERFLOW - Fire all bullets at once
class BufferOverflowGlitch extends Glitch:
	var bullet_count: int = 12

	func _init() -> void:
		glitch_name = "Buffer Overflow"
		description = "Fire bullets in all directions"
		cooldown = 10.0
		duration = 0.0  # Instant
		energy_cost = 35
		icon_color = Color.ORANGE
		screen_shake = 8.0
		glitch_particles = true

	func activate(player: Node2D) -> bool:
		if not super.activate(player):
			return false

		# Find gun controller
		var gun_controller = null
		for child in player.get_children():
			if child is GunController:
				gun_controller = child
				break

		if not gun_controller or not gun_controller.bullet_scene:
			print("GLITCH: No gun controller found!")
			is_active = false
			return false

		# Spawn bullets in a circle
		var angle_step: float = 360.0 / bullet_count
		for i in range(bullet_count):
			var bullet = gun_controller.bullet_scene.instantiate()
			player.get_tree().root.add_child(bullet)
			bullet.global_position = player.global_position

			var angle: float = deg_to_rad(i * angle_step)
			var direction: Vector2 = Vector2(cos(angle), sin(angle))

			var current_gun = gun_controller.current_gun
			if current_gun:
				bullet.initialize(direction, current_gun.bullet_speed, current_gun.damage, Color.RED)

		print("GLITCH: Buffer Overflow - ", bullet_count, " bullets fired!")
		is_active = false
		return true

## MEMORY LEAK - Leave a damaging trail behind
class MemoryLeakGlitch extends Glitch:
	var trail_scene: PackedScene
	var spawn_interval: float = 0.1
	var time_since_spawn: float = 0.0
	var player_ref: Node2D = null

	func _init() -> void:
		glitch_name = "Memory Leak"
		description = "Leave a damaging trail"
		cooldown = 15.0
		duration = 6.0
		energy_cost = 30
		icon_color = Color.RED
		is_toggle = false
		glitch_particles = true

	func activate(player: Node2D) -> bool:
		if not super.activate(player):
			return false

		player_ref = player
		time_since_spawn = 0.0
		print("GLITCH: Memory Leak activated - Leaving trail!")
		return true

	func process(player: Node2D, delta: float) -> void:
		time_since_spawn += delta

		if time_since_spawn >= spawn_interval:
			time_since_spawn = 0.0
			spawn_trail_particle(player.global_position)

	func spawn_trail_particle(pos: Vector2) -> void:
		# Create a simple damaging area
		var area := Area2D.new()
		area.collision_layer = 2
		area.collision_mask = 4  # Hit enemies

		var shape := CircleShape2D.new()
		shape.radius = 15.0
		var collision := CollisionShape2D.new()
		collision.shape = shape
		area.add_child(collision)

		var visual := ColorRect.new()
		visual.size = Vector2(30, 30)
		visual.position = Vector2(-15, -15)
		visual.color = Color(1, 0, 0, 0.5)
		area.add_child(visual)

		if player_ref:
			player_ref.get_tree().root.add_child(area)
		area.global_position = pos

		# Connect damage signal
		area.body_entered.connect(func(body):
			if body.has_method("take_damage"):
				body.take_damage(5)
		)

		# Fade out and delete after 2 seconds
		var tween := area.create_tween()
		tween.tween_property(visual, "modulate:a", 0.0, 2.0)
		tween.tween_callback(area.queue_free)

	func deactivate(player: Node2D) -> void:
		player_ref = null
		super.deactivate(player)
		print("GLITCH: Memory Leak ended")

## STACK OVERFLOW - Create temporary clones
class StackOverflowGlitch extends Glitch:
	var clone_count: int = 3
	var clones: Array = []

	func _init() -> void:
		glitch_name = "Stack Overflow"
		description = "Create temporary clones"
		cooldown = 20.0
		duration = 8.0
		energy_cost = 50
		icon_color = Color(1, 1, 0, 0.7)
		glitch_particles = true

	func activate(player: Node2D) -> bool:
		if not super.activate(player):
			return false

		# Create clones around player
		for i in range(clone_count):
			var clone = create_clone(player, i)
			if clone:
				clones.append(clone)

		print("GLITCH: Stack Overflow - ", clones.size(), " clones created!")
		return true

	func create_clone(player: Node2D, index: int) -> Node2D:
		# Simple clone representation (you'd want to make this more sophisticated)
		var clone := Node2D.new()

		# Add visual
		var sprite := ColorRect.new()
		sprite.size = Vector2(30, 50)
		sprite.position = Vector2(-15, -25)
		sprite.color = Color(1, 1, 0, 0.5)
		clone.add_child(sprite)

		player.get_tree().root.add_child(clone)

		# Position in circle around player
		var angle: float = (TAU / clone_count) * index
		clone.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * 80

		return clone

	func process(player: Node2D, _delta: float) -> void:
		# Make clones orbit around player
		var time: float = Time.get_ticks_msec() / 1000.0
		for i in range(clones.size()):
			var clone = clones[i]
			if is_instance_valid(clone):
				var angle: float = (TAU / clone_count) * i + time
				clone.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * 80

	func deactivate(player: Node2D) -> void:
		super.deactivate(player)

		# Remove all clones
		for clone in clones:
			if is_instance_valid(clone):
				clone.queue_free()

		clones.clear()
		print("GLITCH: Stack Overflow ended - Clones despawned")

## Helper function to create all glitch types
static func get_all_glitches() -> Array[Glitch]:
	return [
		NoclipGlitch.new(),
		BlinkGlitch.new(),
		DuplicationGlitch.new(),
		TimeDesyncGlitch.new(),
		BufferOverflowGlitch.new(),
		MemoryLeakGlitch.new(),
		StackOverflowGlitch.new()
	]

static func get_basic_glitches() -> Array[Glitch]:
	return [
		BlinkGlitch.new(),
		NoclipGlitch.new(),
		DuplicationGlitch.new()
	]
