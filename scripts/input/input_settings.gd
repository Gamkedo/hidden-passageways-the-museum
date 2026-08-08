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
