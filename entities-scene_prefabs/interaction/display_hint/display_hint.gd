class_name DisplayHint
extends Sprite2D


@export var display_target: Node3D
@export var fade_speed: float = 4

## The size of the hint is interpolated between two scale values relative to its distance
## from the player. The hint shrinks when further away, and grows when closer.
## At each extreme:
##  - there is a MAX distance the hint will SHRINK to its MIN SCALE
##  - there is a MAX distance the hint will GROW to its MAX SCALE
##  - between these two distance values, the scale is interpolated between the MAX and MIN values
##
## Visual description:
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## ---           min_scale <--->  current scale   <---> max_scale         ---
## --- max_shrink_distance <---> current distance <---> max_grow_distance ---
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
@export_category("Grow & Shrink Rules")
## Beyond this distance, the hint will be fully hidden
@export var max_visible_distance: float = 10.0
## When the hint is further from the player than this distance, it will not shrink further
@export var max_shrink_distance: float = 7.0
## Min scale the hint shrinks to when further than [max_shrink_distance]
@export var min_scale: float = 0.1
## When the hint is closer to the player than this distance, it will not grow further
@export var max_grow_distance: float = 0.3
## Max scale the hint grows to when closer than [max_grow_distance]
@export var max_scale: float = 1.0


var displaying: bool = false
func show_hint() -> void:
	displaying = true

func hide_hint() -> void:
	displaying = false

## Project position onto the 2D viewport based on position to the camera
func set_position_for_camera(current_camera: Camera3D) -> void:
	var parent_3d := _get_parent_3d()
	# Hide the hint if it's behind the camera
	visible = not current_camera.is_position_behind(parent_3d.global_transform.origin)
	var updated_position := get_target_position_from_camera(current_camera, parent_3d)
	position = updated_position

func get_target_position_from_camera(camera: Camera3D, target_node: Node3D) -> Vector2:
	var target_location: Vector3 = target_node.global_position
	var target_position := camera.unproject_position(target_location)
	return target_position

## Scale the sprite based on distance to the camera
func set_scale_for_camera(current_camera: Camera3D) -> void:
	var curr_distance := _get_distance_to_camera(current_camera)
	var grow_shrink_range := max_shrink_distance - max_grow_distance
	var curr_distance_curve := (grow_shrink_range - curr_distance) / grow_shrink_range
	curr_distance_curve = clampf(curr_distance_curve, min_scale, max_scale)
	scale = Vector2.ONE * curr_distance_curve

## Fade in/out the sprite based on target display state
func set_opacity_for_state(current_camera: Camera3D, display_state: bool, delta: float) -> void:
	var curr_distance := _get_distance_to_camera(current_camera)
	var within_max_display_distance := curr_distance < max_visible_distance
	var should_display := display_state and within_max_display_distance
	var updated_opacity := _get_adjusted_display_opacity(delta, should_display)
	self_modulate.a = updated_opacity

func _get_distance_to_camera(camera: Camera3D) -> float:
	var parent_3d := _get_parent_3d()
	var curr_distance := camera.global_position.distance_to(parent_3d.global_position)
	return curr_distance

func _get_adjusted_display_opacity(delta: float, display: bool) -> float:
	var new_opacity := self_modulate.a
	
	var transition_speed := fade_speed * delta
	if display:
		new_opacity = move_toward(new_opacity, 1, transition_speed)
	else:
		new_opacity = move_toward(new_opacity, 0, transition_speed)
	
	new_opacity = clampf(new_opacity, 0, 1)
	return new_opacity


## Set various attributes every frame
func _process(delta: float) -> void:
	# Current active camera
	var viewport_camera := get_viewport().get_camera_3d()
	
	set_position_for_camera(viewport_camera)
	set_scale_for_camera(viewport_camera)
	set_opacity_for_state(viewport_camera, displaying, delta)

func _get_parent_3d() -> Node3D:
	var parent_3d: Node3D = get_parent()
	if is_instance_valid(display_target):
		parent_3d = display_target
	return parent_3d
