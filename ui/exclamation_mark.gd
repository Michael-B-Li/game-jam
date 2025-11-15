extends TextureRect

# Animation settings
@export var fade_duration: float = 1.0
@export var fade_delay: float = 0.5
@export var pixelated: bool = true

var tween: Tween
var time_elapsed: float = 0.0

func _ready():
	# Ensure pixelated look
	if pixelated:
		texture_filter = TEXTURE_FILTER_NEAREST

	# Start the animation loop
	start_animation()

func start_animation():
	# Cancel any existing tween
	if tween:
		tween.kill()

	# Create new tween for fade in/out effect
	tween = create_tween()
	tween.set_loops()

	# Fade in
	tween.tween_property(self, "modulate:a", 1.0, fade_duration).from(0.0)
	# Stay visible
	tween.tween_interval(fade_delay)
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	# Stay invisible
	tween.tween_interval(fade_delay)

func _exit_tree():
	# Clean up tween when node is removed
	if tween:
		tween.kill()
