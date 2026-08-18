class_name InputController
extends Node

# Override these functions to respond to inputs

# Physics handlers
func _handle_aim(_aim_vector: Vector2, _delta: float) -> void: pass
func _handle_movement(_movement_vector: Vector2, _delta: float) -> void: pass

# Input event handlers
func _handle_mouse_movement(_mouse_motion_event: InputEventMouseMotion) -> void: pass
func _handle_sprint(_is_pressed: bool, _is_released: bool) -> void: pass
func _handle_jump(_is_pressed: bool) -> void: pass
func _handle_interact(_is_pressed: bool) -> void: pass
func _handle_toggle_flight(_is_pressed: bool) -> void: pass
func _handle_capture_mouse(_is_pressed: bool) -> void: pass
func _handle_release_mouse(_is_pressed: bool) -> void: pass

# For adding custom behavior without overriding parent behavior
func _physics_process_callback(_delta: float) -> void: pass
func _process_callback(_delta: float) -> void: pass

func _physics_process(delta: float) -> void:
	_physics_process_callback(delta)
	
	# We handle these in the physics process so that we can register the input
	# on every frame. If we only handle the Input events (via _unhandled_input)
	# we can only react to "changes" in the input. For example, if I hold "forward"
	# on my controller joystick, the input would only be processed "once".
	# This is more important for analog-type inputs than digital ones.
	var current_look_vector := get_aim_vector()
	_handle_aim(current_look_vector, delta)
	
	var current_movement := get_movement_input_vector()
	_handle_movement(current_movement, delta)

func _process(delta: float) -> void:
	_process_callback(delta)

func get_movement_input_vector() -> Vector2:
	var movement_input := Input.get_vector("left", "right", "up", "down")
	return movement_input

func get_aim_vector() -> Vector2:
	var aim_vector := _get_controller_aim_vector()
	return aim_vector

func _get_controller_aim_vector() -> Vector2:
	var controller_aim_vector := Input.get_vector("look_right", "look_left", "look_down", "look_up")
	return controller_aim_vector

func _get_mouse_aim_vector_from_event(mouse_motion_event: InputEventMouseMotion) -> Vector2:
	return mouse_motion_event.screen_relative * -1

# Respond to Input events - ie. changes in received inputs
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_movement(event)
	if event.is_action("capture_mouse"):
		var capture_mouse_is_pressed := Input.is_action_just_pressed_by_event("capture_mouse", event)
		_handle_capture_mouse(capture_mouse_is_pressed)
	if event.is_action("release_mouse"):
		var release_mouse_is_pressed := Input.is_action_just_pressed_by_event("release_mouse", event)
		_handle_release_mouse(release_mouse_is_pressed)
	
	if event.is_action("jump"):
		var jump_is_pressed := Input.is_action_just_pressed_by_event("jump", event)
		_handle_jump(jump_is_pressed)
	if event.is_action("sprint"):
		var sprint_is_pressed := Input.is_action_just_pressed_by_event("sprint", event)
		var sprint_is_released := Input.is_action_just_released_by_event("sprint", event)
		_handle_sprint(sprint_is_pressed, sprint_is_released)
	if event.is_action("interact"):
		var interact_is_pressed := Input.is_action_just_pressed_by_event("interact", event)
		_handle_interact(interact_is_pressed)
	if event.is_action("toggle_flight"):
		var toggle_flight_is_pressed := Input.is_action_just_pressed_by_event("toggle_flight", event)
		_handle_toggle_flight(toggle_flight_is_pressed)
