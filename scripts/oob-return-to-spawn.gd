extends RigidBody3D

var _onready_global_origin: Vector3

func _ready() -> void:
	_onready_global_origin = global_position

func reset_position(to: Vector3) -> void:
	global_position = to
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	reset_physics_interpolation()

func _on_body_entered(body: Node) -> void:
	if body.get_meta(CharacterController.RESET_POSITION_META, false) == true:
		reset_position(_onready_global_origin)
