class_name ControlSettings
extends RefCounted

# !! WARNING !!
# These strings MUST match what is saved in "Project -> Project Settings -> Input Map"
# If these do not match the names of the actions, they won't be applied correctly
const ACTIONS := [
	"left", "right", "up", "down",
	"look_left", "look_right", "look_up", "look_down",
	"jump", "sprint", "interact", "toggle_flight",
	"pause", "map",
	"capture_mouse", "release_mouse"
]


static func get_controls_from_input_map() -> Dictionary[String, InputEvent]:
	var input_map_controls := {}
	for action_name in ACTIONS:
		var input_events := InputMap.action_get_events(action_name)
		input_map_controls[action_name] = input_events
	
	return input_map_controls


static func save_to_input_map(input_mappings: Dictionary[String, InputEvent]) -> void:
	for action_name in input_mappings:
		# Erase all existing actions, overwrite with new set of events
		InputMap.action_erase_events(action_name)
		
		var new_input_actions := input_mappings[action_name]
		for action_event in new_input_actions:
			InputMap.action_add_event(action_name, action_event)
