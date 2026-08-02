class_name PauseScreenButton
extends Button

# Note: I tried to implement this "on-hover/focus" gradient transition
# through several methods, but this was the only I could really get working.
# - StyleBoxes are Resources, so they are 1 shared instance
#   - Changing 1 changes all (unless you dupe it)
# - StyleBoxes can't be tween-ed directly, can only tween the lowest-level attribute
#   - So for the gradient, you have to drill all the way down to the gradient properties
# - Shader material on the button itself doesn't work as it also applies to the text
#   - And the text behaves weird with the shader? Possibly due to how the font is managed
# - I couldn't get a StyleBoxTexture to work with a MeshTexture, regardless of mesh type

@export var normal_gradient: Gradient = preload("uid://cr4y8p2hu8bdr")
@export var focus_gradient: Gradient = preload("uid://cb54qh0q8yv1o")
@export var transition_in_speed: float = 5.0
@export var transition_out_speed: float = 7.0

var curr_state: DrawMode

var override_stylebox: StyleBoxTexture

func _ready() -> void:
	# Ensure styleboxes are unique to this button, so modifications don't affect all using the theme
	override_stylebox = get_theme_stylebox('normal').duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	# Set all styleboxes to the same stylebox, then we'll just react based on the state
	add_theme_stylebox_override('normal', override_stylebox)
	add_theme_stylebox_override('focus', override_stylebox)
	add_theme_stylebox_override('hover', override_stylebox)
	
	mouse_exited.connect(_on_mouse_exited)


func _process(delta: float) -> void:
	# This draw mode updates per the built-in triggers that would change the StyleBox
	curr_state = get_draw_mode()
	match (curr_state):
		DrawMode.DRAW_NORMAL:
			if has_focus():
				_animate_towards_focused_state(delta)
			else:
				_animate_towards_normal_state(delta)
		DrawMode.DRAW_HOVER:
			_animate_towards_focused_state(delta)
			if not has_focus():
				grab_focus()


func _animate_towards_focused_state(delta: float) -> void:
	var curr_texture := override_stylebox.texture as GradientTexture1D
	var curr_gradient := curr_texture.gradient
	_animate_gradient_towards(curr_gradient, focus_gradient, delta * transition_in_speed)


func _animate_towards_normal_state(delta: float) -> void:
	var curr_texture := override_stylebox.texture as GradientTexture1D
	var curr_gradient := curr_texture.gradient
	_animate_gradient_towards(curr_gradient, normal_gradient, delta * transition_out_speed)


func _animate_gradient_towards(start_gradient: Gradient, end_gradient: Gradient, weight: float) -> void:
	var start_colors := start_gradient.colors
	var end_colors := end_gradient.colors
	if start_colors.size() != end_colors.size():
		printerr("Gradients are not matching sizes! Probably not intended")
	
	var new_colors: PackedColorArray
	for color_index in range(start_colors.size()):
		var new_adjusted_color: Color = lerp(start_gradient.colors[color_index], end_gradient.colors[color_index], weight)
		new_colors.push_back(new_adjusted_color)
	start_gradient.colors = new_colors

func _on_mouse_exited():
	# Do this at end-of-frame so other listeners can also react to this while it's still in focus
	release_focus.call_deferred()
