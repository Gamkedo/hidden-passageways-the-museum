class_name CharacterController
extends InputController

signal jumped
signal interact_started
signal interact_stopped

@export var target_node: CharacterBody3D
@export var target_camera: Camera3D

const DEFAULT_CHARACTER_CONTROL_PROPERTIES = preload("uid://cnjhwt3wsomqd")
@export var character_control_properties: CharacterControlProperties = DEFAULT_CHARACTER_CONTROL_PROPERTIES
const INPUT_SETTINGS = preload("uid://b0g4cokh6wa10")
@export var input_settings: InputSettings = INPUT_SETTINGS

@export_subgroup("Enabled Abilities")
@export var movement_enabled: bool = true
@export var jump_enabled: bool = true
@export var sprint_enabled: bool = true:
	set = set_sprint_enabled
@export var interact_enabled: bool = true
@export var interact_distance: float = 3.0
@export_flags_3d_physics var interact_mask: int = 1 ## i dont know what the default value should be in integer format but it isn't just 1.
@export var flight_enabled: bool = true:
	set = set_flight_enabled

enum STATE {GROUNDED, AIRBORNE, FLYING}

var current_available_air_jumps: int = 0

var _last_movement_vector: Vector2 = Vector2.ZERO
var _is_sprinting: bool = false
var _is_interacting: bool = false
var _flight_mode_active: bool = false
var _coyote_frame_timer: int = 0

#region Aiming & Mouse Capture
func _handle_aim(aim_vector: Vector2, delta: float) -> void:
	var adjusted_aim_vector := aim_vector * delta
	
	# Apply input settings
	adjusted_aim_vector.x *= input_settings.controller_horizontal_sensitivity
	adjusted_aim_vector.y *= input_settings.controller_vertical_sensitivity
	if input_settings.controller_invert_y_look:
		adjusted_aim_vector.y *= -1
	
	_apply_aim_rotation(adjusted_aim_vector)

# Mouse movements are weird...
func _handle_mouse_movement(mouse_motion_event: InputEventMouseMotion) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var mouse_vector := _get_mouse_aim_vector_from_event(mouse_motion_event)
	mouse_vector *= 0.003 # Normalize mouse movement, prevent nausea
	
	# Apply input settings
	mouse_vector.x *= input_settings.mouse_horizontal_sensitivity
	mouse_vector.y *= input_settings.mouse_vertical_sensitivity
	if input_settings.mouse_invert_y_look:
		mouse_vector.y *= -1
	
	_apply_aim_rotation(mouse_vector)

func _apply_aim_rotation(aim_vector: Vector2) -> void:
	var horizontal_aim := aim_vector.x
	var vertical_aim := aim_vector.y
	
	target_node.rotate_y(horizontal_aim)
	# Prevent rotation from increasing to number boundary
	target_node.rotation.y = fmod(target_node.rotation.y, 2 * PI)
	
	target_camera.rotate_x(vertical_aim)
	# Prevent looking past straight up or down
	target_camera.rotation.x = clamp(
		target_camera.rotation.x,
		input_settings.min_camera_down,
		input_settings.max_camera_up
	)

func _handle_capture_mouse(_is_pressed: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _handle_release_mouse(_is_pressed: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#endregion Aiming & Mouse Capture

#region Movement
func _handle_movement(movement_vector: Vector2, delta: float) -> void:
	if not movement_enabled:
		return
	
	if _flight_mode_active:
		# No gravity for flight mode
		target_node.velocity.y = 0
	else:
		# Apply gravity
		target_node.velocity += target_node.get_gravity() * delta
	
	# Apply movement (horizontal only)
	var new_velocity := _calculate_movement_velocity(target_node.velocity, movement_vector, delta)
	target_node.velocity.x = new_velocity.x
	target_node.velocity.z = new_velocity.z
	
	#print("Player moving!")
	target_node.move_and_slide()
	
	_last_movement_vector = movement_vector

func _calculate_movement_velocity(
	current_velocity: Vector3,
	movement_vector: Vector2,
	delta: float
) -> Vector3:
	var acceleration := _get_target_acceleration_rate(_last_movement_vector, movement_vector)
	var target_velocity := _get_target_velocity(_last_movement_vector, movement_vector)
	
	var world_movement_vector := _translate_movement_to_world(movement_vector)
	var target_velocity_vector := world_movement_vector * target_velocity
	
	var new_velocity := current_velocity.lerp(target_velocity_vector, acceleration * delta)
	return new_velocity

func _translate_movement_to_world(movement_vector: Vector2) -> Vector3:
	var world_movement_vector := Vector3.ZERO
	# Horizontal only - ignore the 'y' for 3rd-dimension
	world_movement_vector.x = movement_vector.x
	world_movement_vector.z = movement_vector.y
	
	# Straight from the Godot docs :)
	var cam_basis = target_camera.global_transform.basis
	cam_basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	world_movement_vector = cam_basis * world_movement_vector
	
	return world_movement_vector

func _get_target_acceleration_rate(
	prev_movement_vector: Vector2,
	new_movement_vector: Vector2
) -> float:
	# '<=' ensures that we keep the regular acceleration rate when moving at the same speed
	var is_accelerating := prev_movement_vector.length() <= new_movement_vector.length()
	var current_state := get_current_state()
	var target_acceleration := _get_acceleration_for_state(current_state, is_accelerating)
	return target_acceleration

func _get_target_velocity(
	prev_movement_vector: Vector2,
	new_movement_vector: Vector2
) -> float:
	var target_velocity: float
	
	var is_accelerating: bool = prev_movement_vector.length() <= new_movement_vector.length()
	if is_accelerating:
		var current_state := get_current_state()
		target_velocity = _get_max_velocity_for_state(current_state)
	else:
		target_velocity = 0
	
	return target_velocity
#endregion Movement

#region Sprint
func _handle_sprint(is_pressed: bool) -> void:
	if not sprint_enabled:
		return
	
	var toggle_sprint := input_settings.toggle_sprint
	# Toggle sprint on/off on press
	if toggle_sprint:
		if is_pressed:
			_is_sprinting = !_is_sprinting
			#print("Sprint is now:", _is_sprinting)
	# Enable sprint on press, disable on release
	else:
		_is_sprinting = is_pressed
		#print("Sprint is now:", _is_sprinting)

func set_sprint_enabled(enabled: bool) -> void:
	sprint_enabled = enabled
	if not sprint_enabled:
		_is_sprinting = false
#endregion Sprint

#region Jump
func _handle_jump(is_pressed: bool) -> void:
	if not jump_enabled:
		return
	
	if is_pressed:
		var curr_state := get_current_state()
		# Can always jump while on the floor
		if curr_state == STATE.GROUNDED:
			jump()
		elif curr_state == STATE.AIRBORNE:
			if _coyote_frame_timer < character_control_properties.coyote_frames:
				#print("Controller is coyote jumping!")
				jump()
			elif current_available_air_jumps > 0:
				#print("Controller is air jumping")
				# Consume and use an air jump
				current_available_air_jumps -= 1
				jump()

func jump() -> void:
	target_node.velocity.y = character_control_properties.jump_velocity
	# Consume the coyote jump
	_coyote_frame_timer = character_control_properties.coyote_frames
	jumped.emit()

# Process this in the non-physics cycle so that the coyote frame timer is consistent
func _process_coyote_jump() -> void:
	var curr_state := get_current_state()
	if curr_state == STATE.GROUNDED and _coyote_frame_timer > 0:
		# Reset coyote timer for next use
		_coyote_frame_timer = 0
	elif _can_coyote_jump(curr_state):
		_coyote_frame_timer += 1

func _can_coyote_jump(curr_state: STATE) -> bool:
	var can_coyote_jump := curr_state == STATE.AIRBORNE and _coyote_frame_timer < character_control_properties.coyote_frames
	return can_coyote_jump
#endregion Jump

#region Interact
func _handle_interact(is_pressed: bool) -> void:
	if not interact_enabled:
		return
	
	# hack ?
	if not is_pressed:
		return
	#print("interacted")
	interaction_check()
	
	## hook this back up when interactions are redone
	#if is_pressed and not _is_interacting:
		#_is_interacting = true
		#interact_started.emit()
	#else:
		#if _is_interacting:
			#interact_stopped.emit()
		#_is_interacting = false

## adapted from old code
func interaction_check():
	var space_state = target_node.get_world_3d().direct_space_state

	var from = target_camera.global_transform.origin
	var to = from + (-target_camera.global_transform.basis.z * interact_distance)

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = interact_mask

	var result = space_state.intersect_ray(query)
	print("interaction: ", result)
	if result:
		var hit = result.collider
		if hit.has_method("open_link"):
			hit.open_link()
		if hit.has_method("open_scene"):
			hit.open_scene()
		if hit.has_method("manipulate_mesh"):
			hit.manipulate_mesh()
		if hit.has_method("teleport"):
			hit.teleport(self.get_parent()) # need "Player with UI" node here

#endregion Interact

#region Flight
func _handle_toggle_flight(is_pressed: bool) -> void:
	if not flight_enabled:
		return
	
	# Toggle flight mode on press
	if is_pressed:
		_flight_mode_active = !_flight_mode_active

func set_flight_enabled(enabled: bool) -> void:
	flight_enabled = enabled
	if not flight_enabled:
		_flight_mode_active = false
#endregion Flight

#region State Management
func get_current_state() -> STATE:
	var current_state: STATE
	if _flight_mode_active:
		current_state = STATE.FLYING
	elif target_node.is_on_floor():
		current_state = STATE.GROUNDED
	else:
		current_state = STATE.AIRBORNE
	return current_state

func _get_acceleration_for_state(state: STATE, is_accelerating: bool) -> float:
	var target_acceleration: float
	match state:
		STATE.GROUNDED:
			if is_accelerating:
				target_acceleration = character_control_properties.acceleration_rate
			else:
				target_acceleration = character_control_properties.decceleration_rate
		STATE.AIRBORNE:
			if is_accelerating:
				target_acceleration = character_control_properties.air_acceleration
			else:
				target_acceleration = character_control_properties.air_decceleration
		STATE.FLYING:
			if is_accelerating:
				target_acceleration = character_control_properties.flight_acceleration
			else:
				target_acceleration = character_control_properties.flight_decceleration
		_: # default
			target_acceleration = character_control_properties.acceleration_rate
	return target_acceleration

func _get_max_velocity_for_state(state: STATE) -> float:
	var max_velocity: float
	match state:
		STATE.GROUNDED:
			if _is_sprinting:
				max_velocity = character_control_properties.max_sprint_velocity
			else:
				max_velocity = character_control_properties.max_velocity
		STATE.AIRBORNE:
			max_velocity = character_control_properties.max_air_velocity
		STATE.FLYING:
			max_velocity = character_control_properties.max_flight_velocity
		_: # default
			max_velocity = character_control_properties.max_velocity
	return max_velocity
#endregion State Management

func _physics_process_callback(_delta: float) -> void:
	var curr_state := get_current_state()
	if curr_state == STATE.GROUNDED:
		current_available_air_jumps = character_control_properties.max_air_jumps

func _process_callback(_delta: float) -> void:
	_process_coyote_jump()
