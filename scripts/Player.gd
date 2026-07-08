extends RigidBody3D

# this script was started based on the short tutorial at:
# https://www.youtube.com/watch?v=fAVetlIROXM

@export var max_distance := 3.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var look_dir: Vector2
@onready var camera = $Camera3D
var look_speed = 50

var lock_mouse = false

### movement

func _physics_process(delta: float) -> void:
	# note: temporarily being lazy about ground check, this could allow wall jumping
	if Input.is_action_just_pressed("jump") and get_contact_count() > 0:
		apply_central_impulse(Vector3.UP * JUMP_VELOCITY)

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		apply_central_force(direction * 60.0)
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
