extends RigidBody3D

# this script was started based on the short tutorial at:
# https://www.youtube.com/watch?v=fAVetlIROXM

@export var max_distance := 3.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var look_dir: Vector2
@onready var camera = %BodyCam
var look_speed = 50

var lock_mouse = false

func _ready():
	# used to check ground contact before jumping
	contact_monitor = true
	max_contacts_reported = 5

func flight_point(nav_point: Vector3) -> Vector3:
	var direction_from_pivot: Vector3 = (nav_point - flight_pivot_point).normalized()
	return flight_pivot_point + direction_from_pivot * flight_height

### Aim: Origin and direction
func get_player_aim() -> Array[Vector3]:
	var screen_center = get_viewport().get_visible_rect().size / 2.0
	return [camera.project_ray_origin(screen_center), camera.project_ray_normal(screen_center)]

### movement
@export var flight_transition_sec: float = 0.2
@export var flight_height: float = 150.
@export var flight_pivot_point: Vector3 = Vector3(50., -100., 10.)
@onready var flight_target_point: Vector3 = global_position
var flight_anchor_point: Vector3
var is_flying: bool = false
var was_flying: bool = is_flying
var flying_transition_tween: Tween:
	set(v):
		if flying_transition_tween: flying_transition_tween.kill()
		flying_transition_tween = v
func _physics_process(delta: float) -> void:
	if was_flying != is_flying:
		if not was_flying:
			flight_anchor_point = Vector3(global_position.x, 0., global_position.z)
			flight_target_point = flight_point(global_position)
			flying_transition_tween = create_tween()
			flying_transition_tween.tween_property(self, "global_position", flight_target_point, flight_transition_sec).set_ease(Tween.EASE_IN_OUT)
			flying_transition_tween.tween_callback(func(): flying_transition_tween = null)
		else:
			var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
			var aim: Array[Vector3] = get_player_aim()
			var raycast_result: Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
				aim[0], aim[0] + aim[1] * 100.
			))
			if "position" in raycast_result:
				flying_transition_tween = create_tween()
				flying_transition_tween.tween_property(
					self, "global_position", raycast_result.position, flight_transition_sec
				).set_ease(Tween.EASE_IN_OUT)
				flying_transition_tween.tween_callback(func(): flying_transition_tween = null)
			else:
				is_flying = true
				camera_shake_smooth()
	was_flying = is_flying

	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_flying and not flying_transition_tween:
		global_position = lerp(global_position, flight_target_point, 0.8)
		if direction:
			flight_anchor_point += direction
			flight_target_point = flight_point(flight_anchor_point)
	else: # Walking movement logic
		# note: temporarily being lazy about ground check, this could allow wall jumping
		if Input.is_action_just_pressed("jump"):
			print( get_contact_count() )
			if get_contact_count() > 0:
				apply_central_impulse(Vector3.UP * JUMP_VELOCITY * 5.0)

		if direction: apply_central_force(direction * 60.0)
		else:
			var ground_speed := Vector3(linear_velocity.x, 0, linear_velocity.z)
			ground_speed = ground_speed.move_toward(Vector3.ZERO, 20.0 * delta)
			linear_velocity.x = ground_speed.x
			linear_velocity.z = ground_speed.z

		# keep lateral speed reasonable
		var horizontal_velocity := Vector3(linear_velocity.x, 0, linear_velocity.z)

		if horizontal_velocity.length() > SPEED:
			horizontal_velocity = horizontal_velocity.normalized() * SPEED
			linear_velocity.x = horizontal_velocity.x
			linear_velocity.z = horizontal_velocity.z

	_rotate_camera(delta)

func _rotate_camera(delta: float, look_modifier: float = 1.0):
	var input = Input.get_vector("look_left","look_right","look_down","look_up")
	look_dir += input
	rotation.y -= look_dir.x * look_speed * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * look_speed * look_modifier * delta, -1.5,1.5)
	look_dir = Vector2.ZERO

### controls
func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		interaction_check()
		if !lock_mouse:
			cursor_lock_toggle()
	if Input.is_action_just_pressed("pause"):
		cursor_lock_toggle()
	if event.is_action_pressed("map"):
		is_flying = !is_flying

func cursor_lock_toggle():
	lock_mouse = !lock_mouse
	if lock_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

### interaction / link opening behavior

func interaction_check():
	var space_state = get_world_3d().direct_space_state

	var from = camera.global_transform.origin
	var to = from + -camera.global_transform.basis.z * max_distance

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result:
		var hit = result.collider
		var dist = global_transform.origin.distance_to(hit.global_position)

		if dist <= max_distance: # can later scan for switches/doors/items/etc
			if hit.has_method("open_link"):
				hit.open_link()
			if hit.has_method("open_scene"):
				hit.open_scene()
@export var camera_shake_intensity: float = 5.
@export var camera_shake_duration: float = 0.1
func camera_shake_smooth(intensity: float = camera_shake_intensity, duration: float = camera_shake_duration) -> Tween:
	var tween = create_tween()
	var steps = 10
	for i in steps:
		var progress = float(i) / steps
		var current_intensity = intensity * (1.0 - progress)  # Decay
		tween.tween_property(camera, "v_offset", randf_range(-current_intensity, current_intensity), duration / steps)
		tween.tween_property(camera, "h_offset", randf_range(-current_intensity, current_intensity), duration / steps)
	tween.tween_property(camera, "v_offset", Vector2.ZERO, 0.1)
	tween.tween_property(camera, "h_offset", Vector2.ZERO, 0.1)
	return tween
