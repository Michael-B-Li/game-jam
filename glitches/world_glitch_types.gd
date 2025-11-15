class_name WorldGlitchTypes

## Specific world glitch implementations - uncontrollable environmental effects

const WorldGlitch = preload("res://glitches/world_glitch.gd")

## GRAVITY FLIP - Gravity randomly changes direction
class GravityFlipGlitch extends WorldGlitch:
	var original_gravity_direction: Vector2 = Vector2.DOWN
	var flip_directions: Array[Vector2] = [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
	var current_direction: Vector2

	func _init() -> void:
		glitch_name = "Gravity Flip"
		description = "Gravity direction changes randomly"
		duration = 8.0
		severity = 2
		spawn_weight = 15
		min_floor = 2
		visual_effect = "screen_rotate"

	func activate(world: Node2D) -> void:
		super.activate(world)
		# Pick random gravity direction (not down)
		current_direction = flip_directions[randi() % flip_directions.size()]

		# Apply to all physics objects
		var bodies = world.get_tree().get_nodes_in_group("enemies")
		bodies.append_array(world.get_tree().get_nodes_in_group("projectiles"))

		for body in bodies:
			if body is RigidBody2D:
				affected_objects.append(body)
				body.gravity_scale = 1.0
				# Apply force in new direction
				body.apply_central_impulse(current_direction * 100)

	func deactivate(world: Node2D) -> void:
		super.deactivate(world)
		# Reset gravity for affected objects
		for body in affected_objects:
			if is_instance_valid(body) and body is RigidBody2D:
				body.gravity_scale = 0.0

## SCREEN TEAR - Screen randomly splits and offsets
class ScreenTearGlitch extends WorldGlitch:
	var tear_offset: float = 0.0

	func _init() -> void:
		glitch_name = "Screen Tear"
		description = "Visual glitch - screen splits"
		duration = 6.0
		severity = 1
		spawn_weight = 20
		min_floor = 1
		visual_effect = "screen_tear"

	func activate(world: Node2D) -> void:
		super.activate(world)
		tear_offset = randf_range(20.0, 50.0)

	func process(world: Node2D, delta: float) -> void:
		super.process(world, delta)
		# Oscillate tear effect
		tear_offset = sin(Time.get_ticks_msec() / 100.0) * 30.0

## ENEMY MULTIPLICATION - Enemies randomly duplicate
class EnemyMultiplicationGlitch extends WorldGlitch:
	var multiplication_count: int = 0

	func _init() -> void:
		glitch_name = "Enemy Multiplication"
		description = "Enemies duplicate uncontrollably"
		duration = 10.0
		severity = 3
		spawn_weight = 8
		min_floor = 3
		requires_enemies = true
		visual_effect = "screen_shake"

	func activate(world: Node2D) -> void:
		super.activate(world)
		multiplication_count = 0
		duplicate_enemies(world)

	func process(world: Node2D, delta: float) -> void:
		super.process(world, delta)
		# Duplicate every 2 seconds
		if int(time_remaining) % 2 == 0 and multiplication_count < 3:
			duplicate_enemies(world)

	func duplicate_enemies(world: Node2D) -> void:
		var enemies = world.get_tree().get_nodes_in_group("enemies")
		var to_duplicate: Array = []

		# Only duplicate some enemies
		for enemy in enemies:
			if randf() < 0.3:  # 30% chance per enemy
				to_duplicate.append(enemy)

		for enemy in to_duplicate:
			if is_instance_valid(enemy) and enemy is Node2D:
				var duplicate = enemy.duplicate()
				enemy.get_parent().add_child(duplicate)
				duplicate.global_position = enemy.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
				affected_objects.append(duplicate)
				multiplication_count += 1

		if to_duplicate.size() > 0:
			print("GLITCH: Duplicated ", to_duplicate.size(), " enemies!")

## BULLET NOCLIP - Bullets pass through walls
class BulletNoclipGlitch extends WorldGlitch:
	func _init() -> void:
		glitch_name = "Bullet Noclip"
		description = "Bullets phase through walls"
		duration = 12.0
		severity = 2
		spawn_weight = 12
		min_floor = 2
		requires_player_shooting = true
		visual_effect = "distortion"

	func activate(world: Node2D) -> void:
		super.activate(world)
		print("GLITCH: Bullets passing through walls!")

	func physics_process(world: Node2D, delta: float) -> void:
		super.physics_process(world, delta)
		# Find all bullets and disable wall collision
		var bullets = world.get_tree().get_nodes_in_group("bullets")
		for bullet in bullets:
			if bullet is Area2D and not affected_objects.has(bullet):
				affected_objects.append(bullet)
				# Disable collision with walls (assuming walls are on layer 1)
				bullet.collision_mask &= ~1  # Remove layer 1 from mask

	func deactivate(world: Node2D) -> void:
		# Restore wall collision for affected bullets
		for bullet in affected_objects:
			if is_instance_valid(bullet) and bullet is Area2D:
				bullet.collision_mask |= 1  # Re-enable layer 1
		super.deactivate(world)

## SLOW MOTION - Everything moves at half speed
class SlowMotionGlitch extends WorldGlitch:
	var time_scale: float = 0.5

	func _init() -> void:
		glitch_name = "Slow Motion"
		description = "Time slows down for everything"
		duration = 7.0
		severity = 1
		spawn_weight = 18
		min_floor = 1
		visual_effect = "blur"

	func activate(world: Node2D) -> void:
		super.activate(world)
		Engine.time_scale = time_scale
		print("GLITCH: Time slowed to ", time_scale * 100, "%")

	func deactivate(world: Node2D) -> void:
		Engine.time_scale = 1.0
		super.deactivate(world)

## FAST FORWARD - Everything moves at double speed
class FastForwardGlitch extends WorldGlitch:
	var time_scale: float = 2.0

	func _init() -> void:
		glitch_name = "Fast Forward"
		description = "Time speeds up for everything"
		duration = 6.0
		severity = 2
		spawn_weight = 12
		min_floor = 2
		visual_effect = "blur"

	func activate(world: Node2D) -> void:
		super.activate(world)
		Engine.time_scale = time_scale
		print("GLITCH: Time accelerated to ", time_scale * 100, "%")

	func deactivate(world: Node2D) -> void:
		Engine.time_scale = 1.0
		super.deactivate(world)

## INVISIBLE ENEMIES - Enemies become invisible/translucent
class InvisibleEnemiesGlitch extends WorldGlitch:
	func _init() -> void:
		glitch_name = "Invisible Enemies"
		description = "Enemies fade from view"
		duration = 10.0
		severity = 3
		spawn_weight = 10
		min_floor = 3
		requires_enemies = true
		visual_effect = "distortion"

	func activate(world: Node2D) -> void:
		super.activate(world)
		var enemies = world.get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy is Node2D:
				affected_objects.append(enemy)
				enemy.modulate = Color(1, 1, 1, 0.15)  # Nearly invisible

	func deactivate(world: Node2D) -> void:
		for enemy in affected_objects:
			if is_instance_valid(enemy):
				enemy.modulate = Color.WHITE
		super.deactivate(world)

## CONTROL INVERSION - Player controls are inverted
class ControlInversionGlitch extends WorldGlitch:
	func _init() -> void:
		glitch_name = "Control Inversion"
		description = "Movement controls are reversed"
		duration = 8.0
		severity = 2
		spawn_weight = 15
		min_floor = 2
		visual_effect = "screen_shake"

	func activate(world: Node2D) -> void:
		super.activate(world)
		# This needs to be handled by player script checking if this glitch is active
		print("GLITCH: Controls inverted!")

## RANDOM TELEPORT - Player randomly teleports
class RandomTeleportGlitch extends WorldGlitch:
	var teleport_interval: float = 2.0
	var time_since_teleport: float = 0.0

	func _init() -> void:
		glitch_name = "Random Teleport"
		description = "Player teleports randomly"
		duration = 10.0
		severity = 3
		spawn_weight = 8
		min_floor = 3
		visual_effect = "screen_shake"

	func process(world: Node2D, delta: float) -> void:
		super.process(world, delta)
		time_since_teleport += delta

		if time_since_teleport >= teleport_interval:
			time_since_teleport = 0.0
			teleport_player(world)

	func teleport_player(world: Node2D) -> void:
		var player = world.get_tree().get_first_node_in_group("player")
		if player and player is Node2D:
			# Get viewport size for safe teleport bounds
			var viewport_size = world.get_viewport_rect().size
			var new_pos = Vector2(
				randf_range(100, viewport_size.x - 100),
				randf_range(100, viewport_size.y - 100)
			)
			player.global_position = new_pos
			print("GLITCH: Player teleported!")



## BULLET SPRAY - Player bullets scatter randomly
class BulletSprayGlitch extends WorldGlitch:
	var spread_multiplier: float = 5.0

	func _init() -> void:
		glitch_name = "Bullet Spray"
		description = "Bullets scatter wildly"
		duration = 10.0
		severity = 2
		spawn_weight = 15
		min_floor = 2
		requires_player_shooting = true
		visual_effect = "distortion"

	func activate(world: Node2D) -> void:
		super.activate(world)
		# Player gun controller needs to check if this is active
		print("GLITCH: Bullets spraying everywhere!")

## AMMO DRAIN - Ammo slowly decreases
class AmmoDrainGlitch extends WorldGlitch:
	var drain_interval: float = 1.0
	var time_since_drain: float = 0.0

	func _init() -> void:
		glitch_name = "Ammo Drain"
		description = "Ammo slowly disappears"
		duration = 12.0
		severity = 2
		spawn_weight = 12
		min_floor = 2
		visual_effect = "none"

	func process(world: Node2D, delta: float) -> void:
		super.process(world, delta)
		time_since_drain += delta

		if time_since_drain >= drain_interval:
			time_since_drain = 0.0
			drain_ammo(world)

	func drain_ammo(world: Node2D) -> void:
		var player = world.get_tree().get_first_node_in_group("player")
		if player and player.has("gun_controller"):
			var gun_controller = player.gun_controller
			var current_gun = gun_controller.current_gun
			if current_gun and gun_controller.gun_ammo.has(current_gun):
				var current_ammo = gun_controller.gun_ammo.get(current_gun, 0)
				if current_ammo > 0:
					gun_controller.gun_ammo[current_gun] = current_ammo - 1
					gun_controller.ammo_changed.emit(gun_controller.gun_ammo[current_gun], current_gun.ammo_capacity)
					print("GLITCH: Ammo drained!")

## ENEMY SPEED BOOST - All enemies move faster
class EnemySpeedBoostGlitch extends WorldGlitch:
	var speed_multiplier: float = 1.5

	func _init() -> void:
		glitch_name = "Enemy Speed Boost"
		description = "Enemies move faster"
		duration = 10.0
		severity = 2
		spawn_weight = 15
		min_floor = 2
		requires_enemies = true
		visual_effect = "distortion"

	func activate(world: Node2D) -> void:
		super.activate(world)
		var enemies = world.get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.has("speed"):
				affected_objects.append(enemy)
				enemy.speed *= speed_multiplier
		print("GLITCH: Enemies moving faster!")

	func deactivate(world: Node2D) -> void:
		for enemy in affected_objects:
			if is_instance_valid(enemy) and enemy.has("speed"):
				enemy.speed /= speed_multiplier
		super.deactivate(world)

## LOW RESOLUTION - Graphics become pixelated
class LowResolutionGlitch extends WorldGlitch:
	func _init() -> void:
		glitch_name = "Low Resolution"
		description = "Graphics become heavily pixelated"
		duration = 15.0
		severity = 1
		spawn_weight = 20
		min_floor = 1
		visual_effect = "pixelate"

	func activate(world: Node2D) -> void:
		super.activate(world)
		# Would apply pixelation shader to viewport
		print("GLITCH: Low resolution mode!")

## COLOR CORRUPTION - Colors randomly shift
class ColorCorruptionGlitch extends WorldGlitch:
	func _init() -> void:
		glitch_name = "Color Corruption"
		description = "Colors shift randomly"
		duration = 12.0
		severity = 1
		spawn_weight = 18
		min_floor = 1
		visual_effect = "color_shift"

	func process(world: Node2D, delta: float) -> void:
		super.process(world, delta)
		# Randomly shift colors on all sprites
		var time = Time.get_ticks_msec() / 500.0
		var color_shift = Color(
			sin(time) * 0.5 + 0.5,
			sin(time + 2.0) * 0.5 + 0.5,
			sin(time + 4.0) * 0.5 + 0.5
		)

## SPAWN RAIN - Objects fall from the sky
class SpawnRainGlitch extends WorldGlitch:
	var spawn_interval: float = 0.5
	var time_since_spawn: float = 0.0

	func _init() -> void:
		glitch_name = "Spawn Rain"
		description = "Objects fall from above"
		duration = 8.0
		severity = 3
		spawn_weight = 10
		min_floor = 3
		visual_effect = "screen_shake"

	func process(world: Node2D, delta: float) -> void:
		super.process(world, delta)
		time_since_spawn += delta

		if time_since_spawn >= spawn_interval:
			time_since_spawn = 0.0
			spawn_falling_object(world)

	func spawn_falling_object(world: Node2D) -> void:
		var viewport_size = world.get_viewport_rect().size

		# Create a falling object
		var obj = RigidBody2D.new()
		obj.gravity_scale = 1.0

		var sprite = ColorRect.new()
		sprite.size = Vector2(20, 20)
		sprite.position = Vector2(-10, -10)
		sprite.color = Color(randf(), randf(), randf())
		obj.add_child(sprite)

		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(20, 20)
		collision.shape = shape
		obj.add_child(collision)

		world.add_child(obj)
		obj.global_position = Vector2(randf_range(0, viewport_size.x), -50)
		affected_objects.append(obj)

		# Auto-delete after falling
		await world.get_tree().create_timer(5.0).timeout
		if is_instance_valid(obj):
			obj.queue_free()

## MISPLACED ROOM TRIGGER - Door to next level appears in wrong room
class MisplacedRoomTriggerGlitch extends WorldGlitch:
	var door_node: Node2D = null

	func _init() -> void:
		glitch_name = "Misplaced Room Trigger"
		description = "Door to next level spawns in random location"
		duration = 20.0
		severity = 2
		spawn_weight = 10
		min_floor = 2
		visual_effect = "distortion"

	func activate(world: Node2D) -> void:
		super.activate(world)
		spawn_misplaced_door(world)

	func spawn_misplaced_door(world: Node2D) -> void:
		var viewport_size = world.get_viewport_rect().size

		# Create door visual
		door_node = Node2D.new()

		# Add visual indicator (glowing portal-like door)
		var door_visual = ColorRect.new()
		door_visual.size = Vector2(60, 80)
		door_visual.position = Vector2(-30, -40)
		door_visual.color = Color(0, 1, 0, 0.6)
		door_node.add_child(door_visual)

		# Add pulsing effect visual
		var glow = ColorRect.new()
		glow.size = Vector2(70, 90)
		glow.position = Vector2(-35, -45)
		glow.color = Color(0, 1, 1, 0.3)
		door_node.add_child(glow)

		# Add label
		var label = Label.new()
		label.text = "NEXT LEVEL"
		label.add_theme_font_size_override("font_size", 16)
		label.position = Vector2(-30, -60)
		label.modulate = Color.YELLOW
		door_node.add_child(label)

		# Add interaction area
		var area = Area2D.new()
		area.collision_layer = 0
		area.collision_mask = 1  # Detect player
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(60, 80)
		collision.shape = shape
		area.add_child(collision)
		door_node.add_child(area)

		# Position door randomly
		door_node.global_position = Vector2(
			randf_range(100, viewport_size.x - 100),
			randf_range(100, viewport_size.y - 100)
		)

		world.add_child(door_node)
		affected_objects.append(door_node)

		# Connect to player interaction
		area.body_entered.connect(func(body):
			if body.has_method("add_to_group"):
				print("GLITCH: Player found misplaced door! (Would advance to next level)")
				# In actual game, call level transition here
		)

		print("GLITCH: Misplaced door spawned at ", door_node.global_position)

	func process(world: Node2D, delta: float) -> void:
		super.process(world, delta)

		# Make door pulse/glow
		if is_instance_valid(door_node):
			var pulse = sin(Time.get_ticks_msec() / 200.0) * 0.3 + 0.7
			door_node.modulate = Color(1, 1, 1, pulse)

	func deactivate(world: Node2D) -> void:
		super.deactivate(world)
		print("GLITCH: Misplaced door disappeared")

## Helper function to get all world glitch types
static func get_all_world_glitches() -> Array[WorldGlitch]:
	return [
		ScreenTearGlitch.new(),
		SlowMotionGlitch.new(),
		FastForwardGlitch.new(),
		ColorCorruptionGlitch.new(),
		LowResolutionGlitch.new(),
		BulletSprayGlitch.new(),
		ControlInversionGlitch.new(),
		MisplacedRoomTriggerGlitch.new(),
		EnemySpeedBoostGlitch.new(),
		AmmoDrainGlitch.new(),
		InvisibleEnemiesGlitch.new(),
		RandomTeleportGlitch.new(),
		BulletNoclipGlitch.new(),
		EnemyMultiplicationGlitch.new(),
		GravityFlipGlitch.new(),
		SpawnRainGlitch.new()
	]

static func get_minor_glitches() -> Array[WorldGlitch]:
	return [
		ScreenTearGlitch.new(),
		SlowMotionGlitch.new(),
		ColorCorruptionGlitch.new(),
		LowResolutionGlitch.new()
	]

static func get_moderate_glitches() -> Array[WorldGlitch]:
	return [
		FastForwardGlitch.new(),
		BulletSprayGlitch.new(),
		ControlInversionGlitch.new(),
		EnemySpeedBoostGlitch.new(),
		AmmoDrainGlitch.new(),
		GravityFlipGlitch.new(),
		MisplacedRoomTriggerGlitch.new()
	]

static func get_severe_glitches() -> Array[WorldGlitch]:
	return [
		InvisibleEnemiesGlitch.new(),
		RandomTeleportGlitch.new(),
		EnemyMultiplicationGlitch.new(),
		SpawnRainGlitch.new()
	]
