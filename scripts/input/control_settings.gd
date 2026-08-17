class_name ControlSettings
extends RefCounted

enum ACTIONS {
	LEFT, RIGHT, UP, DOWN,
	LOOK_LEFT, LOOK_RIGHT, LOOK_UP, LOOK_DOWN,
	JUMP, SPRINT, INTERACT, TOGGLE_FLIGHT,
	PAUSE, MAP,
	CAPTURE_MOUSE, RELEASE_MOUSE
}
# !! WARNING !!
# These strings MUST match what is saved in "Project -> Project Settings -> Input Map"
# If these do not match the names of the actions, they won't be applied correctly
const ACTION_STRINGS: Dictionary[ACTIONS, String]= {
	ACTIONS.LEFT: "left", ACTIONS.RIGHT: "right", ACTIONS.UP: "up", ACTIONS.DOWN: "down",
	ACTIONS.LOOK_LEFT: "look_left", ACTIONS.LOOK_RIGHT: "look_right", ACTIONS.LOOK_UP: "look_up", ACTIONS.LOOK_DOWN: "look_down",
	ACTIONS.JUMP: "jump", ACTIONS.SPRINT: "sprint", ACTIONS.INTERACT: "interact", ACTIONS.TOGGLE_FLIGHT: "toggle_flight",
	ACTIONS.PAUSE: "pause", ACTIONS.MAP: "map",
	ACTIONS.CAPTURE_MOUSE: "capture_mouse", ACTIONS.RELEASE_MOUSE: "release_mouse"
}


static func get_controls_from_input_map() -> Dictionary[String, InputEvent]:
	var input_map_controls := {}
	for action_name_key in ACTION_STRINGS:
		var action_name := ACTION_STRINGS[action_name_key]
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


static func remap_event_in_input_map(action_name: StringName, input_event: InputEvent) -> void:
	var existing_events := InputMap.action_get_events(action_name)
	
	# Filter to events that have a matching event type as the given event
	var matching_event_types := existing_events.filter(func (event):
		if input_event is InputEventJoypadButton and event is InputEventJoypadButton:
			return true
		elif input_event is InputEventJoypadMotion and event is InputEventJoypadMotion:
			return true
		elif input_event is InputEventKey and event is InputEventKey:
			return true
		# No match
		return false
	)
	# Remove input event by matching class
	for matched_event in matching_event_types:
		InputMap.action_erase_event(action_name, matched_event)
	
	# Add the new input event for the action
	InputMap.action_add_event(action_name, input_event)
