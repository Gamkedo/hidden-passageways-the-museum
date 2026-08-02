class_name PauseScreenButton
extends Button

@export var normal_gradient: Gradient = preload("uid://cr4y8p2hu8bdr")
@export var focus_gradient: Gradient = preload("uid://cb54qh0q8yv1o")
@export var transition_in_speed: float = 5.0
@export var transition_out_speed: float = 7.0

var curr_state: DrawMode

var override_stylebox: StyleBoxTexture

func _ready() -> void:
	override_stylebox = get_theme_stylebox('normal').duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	# Ensure styleboxes are unique to this button, so modifications don't affect all using the theme
	add_theme_stylebox_override('normal', override_stylebox)
	add_theme_stylebox_override('focus', override_stylebox)
	add_theme_stylebox_override('hover', override_stylebox)
	
	mouse_exited.connect(_on_mouse_exited)


func _process(delta: float) -> void:
	var draw_state := get_draw_mode()
	if curr_state != draw_state:
		curr_state = draw_state
	match (curr_state):
		DrawMode.DRAW_NORMAL:
			if has_focus():
				_animate_towards_focused_state(delta)
			else:
				_animate_towards_normal_state(delta)
		DrawMode.DRAW_HOVER:
			_animate_towards_focused_state(delta)
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
	release_focus.call_deferred()
