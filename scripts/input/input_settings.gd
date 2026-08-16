class_name InputSettings
extends Resource

@export_category("Look/Aim")
@export_range(0, 100) var controller_horizontal_sensitivity: float = 5
@export_range(0, 100) var controller_vertical_sensitivity: float = 4
@export_range(0, 100) var mouse_horizontal_sensitivity: float = 2
@export_range(0, 100) var mouse_vertical_sensitivity: float = 2

@export var controller_invert_y_look: bool = false
@export var mouse_invert_y_look: bool = false

@export var max_camera_up: float = PI / 2.0
@export var min_camera_down: float = PI / -2.0

@export_category("Abilities")
## If true, the sprint button toggles the sprint state. If false, hold to sprint.
@export var toggle_sprint: bool = true


func serialize() -> Dictionary:
	var serialized_settings := {
		"controller_horizontal_sensitivity": 	controller_horizontal_sensitivity,
		"controller_vertical_sensitivity": 		controller_vertical_sensitivity,
		"mouse_horizontal_sensitivity": 		mouse_horizontal_sensitivity,
		"mouse_vertical_sensitivity": 			mouse_vertical_sensitivity,
		"controller_invert_y_look": 			controller_invert_y_look,
		"mouse_invert_y_look": 					mouse_invert_y_look,
		"max_camera_up": 						max_camera_up,
		"min_camera_down": 						min_camera_down,
		"toggle_sprint": 						toggle_sprint,
	}
	return serialized_settings


func load_from_serialized(settings_data: Dictionary) -> void:
	if settings_data.has("controller_horizontal_sensitivity"):
		controller_horizontal_sensitivity = settings_data.get("controller_horizontal_sensitivity")
	if settings_data.has("controller_vertical_sensitivity"):
		controller_vertical_sensitivity = settings_data.get("controller_vertical_sensitivity")
	if settings_data.has("mouse_horizontal_sensitivity"):
		mouse_horizontal_sensitivity = settings_data.get("mouse_horizontal_sensitivity")
	if settings_data.has("mouse_vertical_sensitivity"):
		mouse_vertical_sensitivity = settings_data.get("mouse_vertical_sensitivity")
	if settings_data.has("controller_invert_y_look"):
		controller_invert_y_look = settings_data.get("controller_invert_y_look")
	if settings_data.has("mouse_invert_y_look"):
		mouse_invert_y_look = settings_data.get("mouse_invert_y_look")
	if settings_data.has("max_camera_up"):
		max_camera_up = settings_data.get("max_camera_up")
	if settings_data.has("min_camera_down"):
		min_camera_down = settings_data.get("min_camera_down")
	if settings_data.has("toggle_sprint"):
		toggle_sprint = settings_data.get("toggle_sprint")
