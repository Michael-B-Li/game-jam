extends Node2D

## Example script showing how to integrate WorldGlitchManager into your game
## Attach this to your main game scene or level manager

@onready var world_glitch_manager: WorldGlitchManager = null
@onready var player: Node2D = null

func _ready() -> void:
	# Create and add the world glitch manager
	world_glitch_manager = WorldGlitchManager.new()
	add_child(world_glitch_manager)

	# Configure the manager
	world_glitch_manager.enabled = true
	world_glitch_manager.min_interval = 20.0  # Glitch every 20-40 seconds
	world_glitch_manager.max_interval = 40.0
	world_glitch_manager.max_active_glitches = 2  # Up to 2 simultaneous
	world_glitch_manager.glitch_intensity = 1  # Start with minor glitches
	world_glitch_manager.current_floor = 1

	# Connect signals for feedback
	world_glitch_manager.world_glitch_started.connect(_on_world_glitch_started)
	world_glitch_manager.world_glitch_ended.connect(_on_world_glitch_ended)
	world_glitch_manager.glitch_intensity_changed.connect(_on_intensity_changed)

	# Get player reference
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_to_group("player")  # Make sure player is in group

func _on_world_glitch_started(glitch: WorldGlitch) -> void:
	print("🔥 World Glitch Started: ", glitch.glitch_name)

	# Show visual indicator
	show_glitch_warning(glitch)

	# Play sound effect
	# play_glitch_sound(glitch.severity)

	# Apply screen effects based on glitch
	match glitch.visual_effect:
		"screen_shake":
			apply_screen_shake(5.0)
		"distortion":
			apply_screen_distortion()
		"screen_tear":
			apply_screen_tear()

func _on_world_glitch_ended(glitch: WorldGlitch) -> void:
	print("✅ World Glitch Ended: ", glitch.glitch_name)

	# Clear visual effects
	clear_screen_effects()

func _on_intensity_changed(level: int) -> void:
	print("⚠️ Glitch intensity increased to level ", level)
	# Show warning to player
	# update_ui_danger_level(level)

## Show warning when glitch starts
func show_glitch_warning(glitch: WorldGlitch) -> void:
	# Create temporary warning label
	var warning = Label.new()
	warning.text = "⚠️ " + glitch.glitch_name.to_upper() + " ⚠️"
	warning.add_theme_font_size_override("font_size", 32)
	warning.modulate = glitch.get_severity_color()
	warning.position = Vector2(100, 50)
	add_child(warning)

	# Fade out and remove
	var tween = create_tween()
	tween.tween_property(warning, "modulate:a", 0.0, 2.0)
	tween.tween_callback(warning.queue_free)

## Example: Handle control inversion glitch in player movement
func _process(delta: float) -> void:
	if not player:
		return

	# Check if control inversion is active
	var control_inverted = world_glitch_manager.is_glitch_active("Control Inversion")
	if control_inverted and player.has_method("set_controls_inverted"):
		player.set_controls_inverted(true)

	# Check if bullet spray is active
	var bullet_spray = world_glitch_manager.is_glitch_active("Bullet Spray")
	if bullet_spray and player.has("gun_controller"):
		# Multiply spread by 5x while active
		pass

## Example: Advance to next floor
func advance_to_next_floor() -> void:
	var current_floor = world_glitch_manager.current_floor + 1
	world_glitch_manager.set_floor(current_floor)
	print("Advanced to floor ", current_floor)

## Example: Force trigger a specific glitch (for testing)
func test_trigger_glitch(glitch_name: String) -> void:
	world_glitch_manager.force_trigger_glitch(glitch_name)

## Example: Disable glitches temporarily (boss fight, cutscene, etc)
func disable_glitches_temporarily(duration: float) -> void:
	world_glitch_manager.set_enabled(false)
	await get_tree().create_timer(duration).timeout
	world_glitch_manager.set_enabled(true)

## Example: Make game easier/harder by adjusting glitch frequency
func adjust_difficulty(easier: bool) -> void:
	if easier:
		world_glitch_manager.make_less_frequent()
	else:
		world_glitch_manager.make_more_frequent()

## Screen effect stubs (implement with shaders/camera)
func apply_screen_shake(intensity: float) -> void:
	# TODO: Implement camera shake
	pass

func apply_screen_distortion() -> void:
	# TODO: Apply distortion shader
	pass

func apply_screen_tear() -> void:
	# TODO: Apply screen tear effect
	pass

func clear_screen_effects() -> void:
	# TODO: Clear all screen effects
	pass

## ============================================
## TESTING FUNCTIONS - Use these to test glitches
## ============================================

## Call these from console or debug menu
func test_all_glitches() -> void:
	print("Testing all glitches...")
	var glitches = WorldGlitchTypes.get_all_world_glitches()
	for glitch in glitches:
		print("  - ", glitch.glitch_name)
		world_glitch_manager.start_glitch(glitch)
		await get_tree().create_timer(glitch.duration + 1.0).timeout

func test_minor_glitches() -> void:
	test_trigger_glitch("Screen Shake")
	await get_tree().create_timer(3.0).timeout
	test_trigger_glitch("Screen Tear")

func test_severe_glitches() -> void:
	test_trigger_glitch("Random Teleport")
	await get_tree().create_timer(5.0).timeout
	test_trigger_glitch("Invisible Enemies")

## Print active glitch info
func debug_print_active_glitches() -> void:
	var info = world_glitch_manager.get_active_glitch_info()
	print("=== Active Glitches ===")
	for glitch_info in info:
		print("  ", glitch_info["name"], " - ", glitch_info["time_remaining"], "s remaining")
