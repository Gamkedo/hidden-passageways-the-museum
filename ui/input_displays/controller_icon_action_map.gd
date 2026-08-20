class_name ControllerIconActionMap
extends Resource

const INPUT_BINDS: InputBinds = preload("uid://dnfis17edcjtb")

@export_group("Joysticks")
@export_subgroup("Left Joystick")
@export var left_joystick_left: Dictionary[InputEventJoypadMotion, Texture2D]
@export var left_joystick_right: Dictionary[InputEventJoypadMotion, Texture2D]
@export var left_joystick_up: Dictionary[InputEventJoypadMotion, Texture2D]
@export var left_joystick_down: Dictionary[InputEventJoypadMotion, Texture2D]
@export_subgroup("Right Joystick")
@export var right_joystick_left: Dictionary[InputEventJoypadMotion, Texture2D]
@export var right_joystick_right: Dictionary[InputEventJoypadMotion, Texture2D]
@export var right_joystick_up: Dictionary[InputEventJoypadMotion, Texture2D]
@export var right_joystick_down: Dictionary[InputEventJoypadMotion, Texture2D]

@export_group("Face Buttons")
@export_subgroup("Primary Buttons")
@export var left_face_button: Dictionary[InputEventJoypadButton, Texture2D]
@export var right_face_button: Dictionary[InputEventJoypadButton, Texture2D]
@export var top_face_button: Dictionary[InputEventJoypadButton, Texture2D]
@export var bottom_face_button: Dictionary[InputEventJoypadButton, Texture2D]
@export_subgroup("D-Pad")
@export var dpad_left: Dictionary[InputEventJoypadButton, Texture2D]
@export var dpad_right: Dictionary[InputEventJoypadButton, Texture2D]
@export var dpad_top: Dictionary[InputEventJoypadButton, Texture2D]
@export var dpad_bottom: Dictionary[InputEventJoypadButton, Texture2D]

@export_group("Bumpers & Triggers")
@export_subgroup("Bumpers")
@export var left_bumper: Dictionary[InputEventJoypadButton, Texture2D]
@export var right_bumper: Dictionary[InputEventJoypadButton, Texture2D]
@export_subgroup("Triggers")
@export var left_trigger: Dictionary[InputEventJoypadMotion, Texture2D]
@export var right_trigger: Dictionary[InputEventJoypadMotion, Texture2D]

@export_group("Menu Buttons")
@export var menu_left: Dictionary[InputEventJoypadButton, Texture2D]
@export var menu_right: Dictionary[InputEventJoypadButton, Texture2D]



## This is what drives the mapping in-code to determine which icon to display
func get_icon_for_event(event: InputEvent) -> Texture2D:
	var all_mappings := _get_all_icon_mappings()
	var mapped_events: Array[InputEvent] = all_mappings.keys()
	var matching_mapping_index: int = mapped_events.find_custom(_has_matching_event.bind(event))
	
	var event_icon: Texture2D = null
	if matching_mapping_index != -1:
		var matching_event: InputEvent = mapped_events[matching_mapping_index]
		event_icon = all_mappings[matching_event]
	return event_icon
	

func _has_matching_event(mapping: InputEvent, event: InputEvent) -> bool:
	if event.is_match(mapping):
		return true
	return false

# Get all mappings as a single dictionary
func _get_all_icon_mappings() -> Dictionary[InputEvent, Texture2D]:
	var all_mappings := [
		left_joystick_left,
		left_joystick_right,
		left_joystick_up,
		left_joystick_down,
		right_joystick_left,
		right_joystick_right,
		right_joystick_up,
		right_joystick_down,
		left_face_button,
		right_face_button,
		top_face_button,
		bottom_face_button,
		dpad_left,
		dpad_right,
		dpad_top,
		dpad_bottom,
		left_bumper,
		right_bumper,
		left_trigger,
		right_trigger,
		menu_left,
		menu_right,
	]
	
	var icon_mappings: Dictionary[InputEvent, Texture2D] = {}
	for mapping in all_mappings:
		icon_mappings.merge(mapping)
	return icon_mappings
