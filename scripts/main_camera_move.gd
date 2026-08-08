extends Node3D

# this script is a small workaround to prevent camera shake
# lets camera ignore subtle player physics bounce

@export var physics_child_camera_transform: Marker3D

func set_chase_transform(transform: Marker3D):
	physics_child_camera_transform = transform

func _process(delta: float) -> void:
	global_rotation.y = physics_child_camera_transform.global_rotation.y

func _physics_process(delta: float) -> void:
	var cam_moved_by = global_position - physics_child_camera_transform.global_position
	if cam_moved_by.length() > 0.01:
		global_position = physics_child_camera_transform.global_position
