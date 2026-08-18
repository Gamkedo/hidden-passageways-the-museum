class_name InputSettings
extends SaveableResource

signal input_settings_updated

@export_category("Look/Aim")
@export_range(0, 100) var controller_horizontal_sensitivity: float = 5:
	set = set_controller_horizontal_sensitivity
@export_range(0, 100) var controller_vertical_sensitivity: float = 4:
	set = set_controller_vertical_sensitivity
@export_range(0, 100) var mouse_horizontal_sensitivity: float = 2:
	set = set_mouse_horizontal_sensitivity
@export_range(0, 100) var mouse_vertical_sensitivity: float = 2:
	set = set_mouse_vertical_sensitivity

@export var controller_invert_y_look: bool = false:
	set = set_controller_invert_y_look
@export var mouse_invert_y_look: bool = false:
	set = set_mouse_invert_y_look

@export var max_camera_up: float = PI / 2.0:
	set = set_max_camera_up
@export var min_camera_down: float = PI / -2.0:
	set = set_min_camera_down

@export_category("Abilities")
## If true, the sprint button toggles the sprint state. If false, hold to sprint.
@export var toggle_sprint: bool = true:
	set = set_toggle_sprint

const INPUT_SETTINGS_SECTION := "InputSettings"


func handle_loaded_file(file: ConfigFile) -> void:
	load_from_serialized(file)

func serialize() -> ConfigFile:
	# Only works if these remain as simple Variants/scalars
	# If you put more complex Objects or Resources in here, you'll need to
	# add serilzation/deserialization logic as well!
	# See InputBinds for an example
	var serialized_settings := {
		"controller_horizontal_sensitivity":	controller_horizontal_sensitivity,
		"controller_vertical_sensitivity":		controller_vertical_sensitivity,
		"mouse_horizontal_sensitivity":			mouse_horizontal_sensitivity,
		"mouse_vertical_sensitivity":			mouse_vertical_sensitivity,
		"controller_invert_y_look":				controller_invert_y_look,
		"mouse_invert_y_look":					mouse_invert_y_look,
		"max_camera_up":						max_camera_up,
		"min_camera_down":						min_camera_down,
		"toggle_sprint":						toggle_sprint,
	}
	
	var config_file := ConfigFile.new()
	for setting in serialized_settings:
		config_file.set_value(INPUT_SETTINGS_SECTION, setting, serialized_settings[setting])
	return config_file


func load_from_serialized(settings_data: ConfigFile) -> void:
	print("[InputSettings] Loading input settings from config file")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "controller_horizontal_sensitivity"):
		controller_horizontal_sensitivity = settings_data.get_value(INPUT_SETTINGS_SECTION, "controller_horizontal_sensitivity")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "controller_vertical_sensitivity"):
		controller_vertical_sensitivity = settings_data.get_value(INPUT_SETTINGS_SECTION, "controller_vertical_sensitivity")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "mouse_horizontal_sensitivity"):
		mouse_horizontal_sensitivity = settings_data.get_value(INPUT_SETTINGS_SECTION, "mouse_horizontal_sensitivity")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "mouse_vertical_sensitivity"):
		mouse_vertical_sensitivity = settings_data.get_value(INPUT_SETTINGS_SECTION, "mouse_vertical_sensitivity")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "controller_invert_y_look"):
		controller_invert_y_look = settings_data.get_value(INPUT_SETTINGS_SECTION, "controller_invert_y_look")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "mouse_invert_y_look"):
		mouse_invert_y_look = settings_data.get_value(INPUT_SETTINGS_SECTION, "mouse_invert_y_look")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "max_camera_up"):
		max_camera_up = settings_data.get_value(INPUT_SETTINGS_SECTION, "max_camera_up")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "min_camera_down"):
		min_camera_down = settings_data.get_value(INPUT_SETTINGS_SECTION, "min_camera_down")
	if settings_data.has_section_key(INPUT_SETTINGS_SECTION, "toggle_sprint"):
		toggle_sprint = settings_data.get_value(INPUT_SETTINGS_SECTION, "toggle_sprint")


func emit_input_settings_updated() -> void:
	input_settings_updated.emit()

#region Setters (for signal)
# These are just setters to capture the change and ensure the signal gets emitted
func set_controller_horizontal_sensitivity(val: float) -> void:
	controller_horizontal_sensitivity = val
	emit_input_settings_updated()
func set_controller_vertical_sensitivity(val: float) -> void:
	controller_vertical_sensitivity = val
	emit_input_settings_updated()
func set_mouse_horizontal_sensitivity(val: float) -> void:
	mouse_horizontal_sensitivity = val
	emit_input_settings_updated()
func set_mouse_vertical_sensitivity(val: float) -> void:
	mouse_vertical_sensitivity = val
	emit_input_settings_updated()
func set_controller_invert_y_look(val: bool) -> void:
	controller_invert_y_look = val
	emit_input_settings_updated()
func set_mouse_invert_y_look(val: bool) -> void:
	mouse_invert_y_look = val
	emit_input_settings_updated()
func set_max_camera_up(val: float) -> void:
	max_camera_up = val
	emit_input_settings_updated()
func set_min_camera_down(val: float) -> void:
	min_camera_down = val
	emit_input_settings_updated()
func set_toggle_sprint(val: bool) -> void:
	toggle_sprint = val
	emit_input_settings_updated()
#endregion Setters
