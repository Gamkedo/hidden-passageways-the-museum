class_name StairStepRaycast
extends RayCast3D

@export var target_node: CharacterBody3D
@export var input_controller: InputController

var _initial_distance_to_target: float


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(input_controller):
		return
	
	var input_movement := input_controller.get_movement_input_vector()
	# Only move the raycast when receiving movement input
	# This keeps the raycast at its last position when the movement input goes neutral
	if input_movement.is_zero_approx():
		return
	
	# Rotate the ray cast around the target body while maintaining its initial distance
	var world_movement_vector := Vector3(input_movement.x, 0, input_movement.y).normalized()
	var new_position := world_movement_vector * _initial_distance_to_target
	new_position.y = position.y
	position = new_position


func _ready() -> void:
	if not is_instance_valid(target_node):
		target_node = get_parent_node_3d()
		print("[StairStep] No target node assigned, assuming parent is target. Name: ", target_node.name)
	
	# Ignore y-axis for distance calculation - going for horizontal plane only
	var flattened_position_vector := global_position * Vector3(1, 0, 1)
	var flattened_target_position_vector := target_node.global_position * Vector3(1, 0, 1)
	_initial_distance_to_target = flattened_position_vector.distance_to(flattened_target_position_vector)
