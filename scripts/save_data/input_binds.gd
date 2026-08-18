class_name InputBinds
extends SaveableResource

signal input_map_updated

#region Input Events
@export var left: Array[InputEvent]
@export var right: Array[InputEvent]
@export var up: Array[InputEvent]
@export var down: Array[InputEvent]
@export var look_left: Array[InputEvent]
@export var look_right: Array[InputEvent]
@export var look_up: Array[InputEvent]
@export var look_down: Array[InputEvent]
@export var jump: Array[InputEvent]
@export var sprint: Array[InputEvent]
@export var interact: Array[InputEvent]
@export var toggle_flight: Array[InputEvent]
@export var pause: Array[InputEvent]
@export var map: Array[InputEvent]
@export var capture_mouse: Array[InputEvent]
@export var release_mouse: Array[InputEvent]
#endregion Input Events


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

const INPUT_BINDS_SECTION := "InputBinds"

## Get the controls currently registered in this Resource file
func get_controls() -> Dictionary[String, Array]:
	var controls: Dictionary[String, Array] = {}
	for action_name_key in ACTION_STRINGS:
		var action_name := ACTION_STRINGS[action_name_key]
		var input_events := get_events(action_name)
		controls[action_name] = input_events
	
	return controls

## Get the controls currently stored in the InputMap (active in project)
func get_controls_from_input_map() -> Dictionary[String, Array]:
	var input_map_controls: Dictionary[String, Array] = {}
	for action_name_key in ACTION_STRINGS:
		var action_name := ACTION_STRINGS[action_name_key]
		var input_events := InputMap.action_get_events(action_name)
		input_map_controls[action_name] = input_events
	
	return input_map_controls

func load_from_input_map() -> void:
	var current_controls := get_controls_from_input_map()
	for action_name in current_controls:
		var action_events := current_controls[action_name]
		#print("[InputBinds] Setting [CONTROLS]->'%s' to {%s}" % [action_name, action_events])
		set_event(action_name, action_events)

func save_to_input_map(input_mappings: Dictionary[String, Array]) -> void:
	print("[InputBinds] Saving mappings to InputMap")
	for action_name in input_mappings:
		# Erase all existing actions, overwrite with new set of events
		InputMap.action_erase_events(action_name)
		
		var new_input_actions: Array[InputEvent]
		var target_mappings := input_mappings[action_name]
		new_input_actions.assign(target_mappings)
		for action_event in new_input_actions:
			InputMap.action_add_event(action_name, action_event)
		
		input_map_updated.emit()


func remap_event_in_input_map(action_name: StringName, input_event: InputEvent) -> void:
	print("[InputBinds] Updating input for '%s'" % [action_name])
	var existing_events := InputMap.action_get_events(action_name)
	
	# Filter to events that have a matching event type as the given event
	var type_matched_events := existing_events.filter(func (event: InputEvent):
		if input_event.get_class() == event.get_class():
			return true
		else:
			return false
	)
	# Remove input event by matching class
	for matched_event in type_matched_events:
		InputMap.action_erase_event(action_name, matched_event)
	
	# Add the new input event for the action
	InputMap.action_add_event(action_name, input_event)
	var mapped_events := InputMap.action_get_events(action_name);
	set_event(action_name, mapped_events)
	input_map_updated.emit()


func reset_binds(directory_path: String, file_path: String) -> void:
	var full_path := directory_path + file_path
	var file_exists := FileAccess.file_exists(full_path)
	if file_exists:
		# Will truncate the file to zero bytes
		FileAccess.open(file_path, FileAccess.READ_WRITE)
	
	# Reset the InputMap from ProjectSettings - effectively reset to the beginning
	if not InputMap.project_settings_loaded.is_connected(_on_input_map_loaded_project_settings):
		InputMap.project_settings_loaded.connect(_on_input_map_loaded_project_settings)
	InputMap.load_from_project_settings()

func _on_input_map_loaded_project_settings() -> void:
	var input_map_controls := get_controls_from_input_map()
	for input_action in input_map_controls:
		set_event(input_action, input_map_controls[input_action])
	
	input_map_updated.emit()

func set_event(action: StringName, events: Array[InputEvent]) -> void:
	match action:
		ACTION_STRINGS[ACTIONS.LEFT]:
			left = events
		ACTION_STRINGS[ACTIONS.RIGHT]:
			right = events
		ACTION_STRINGS[ACTIONS.UP]:
			up = events
		ACTION_STRINGS[ACTIONS.DOWN]:
			down = events
		ACTION_STRINGS[ACTIONS.LOOK_LEFT]:
			look_left = events
		ACTION_STRINGS[ACTIONS.LOOK_RIGHT]:
			look_right = events
		ACTION_STRINGS[ACTIONS.LOOK_UP]:
			look_up = events
		ACTION_STRINGS[ACTIONS.LOOK_DOWN]:
			look_down = events
		ACTION_STRINGS[ACTIONS.JUMP]:
			jump = events
		ACTION_STRINGS[ACTIONS.SPRINT]:
			sprint = events
		ACTION_STRINGS[ACTIONS.INTERACT]:
			interact = events
		ACTION_STRINGS[ACTIONS.TOGGLE_FLIGHT]:
			toggle_flight = events
		ACTION_STRINGS[ACTIONS.PAUSE]:
			pause = events
		ACTION_STRINGS[ACTIONS.MAP]:
			map = events
		ACTION_STRINGS[ACTIONS.CAPTURE_MOUSE]:
			capture_mouse = events
		ACTION_STRINGS[ACTIONS.RELEASE_MOUSE]:
			release_mouse = events

func get_events(action: StringName) -> Array[InputEvent]:
	var events: Array[InputEvent]
	match action:
		ACTION_STRINGS[ACTIONS.LEFT]:
			events = left
		ACTION_STRINGS[ACTIONS.RIGHT]: 
			events = right
		ACTION_STRINGS[ACTIONS.UP]: 
			events = up
		ACTION_STRINGS[ACTIONS.DOWN]: 
			events = down
		ACTION_STRINGS[ACTIONS.LOOK_LEFT]: 
			events = look_left
		ACTION_STRINGS[ACTIONS.LOOK_RIGHT]: 
			events = look_right
		ACTION_STRINGS[ACTIONS.LOOK_UP]: 
			events = look_up
		ACTION_STRINGS[ACTIONS.LOOK_DOWN]: 
			events = look_down
		ACTION_STRINGS[ACTIONS.JUMP]: 
			events = jump
		ACTION_STRINGS[ACTIONS.SPRINT]: 
			events = sprint
		ACTION_STRINGS[ACTIONS.INTERACT]: 
			events = interact
		ACTION_STRINGS[ACTIONS.TOGGLE_FLIGHT]: 
			events = toggle_flight
		ACTION_STRINGS[ACTIONS.PAUSE]: 
			events = pause
		ACTION_STRINGS[ACTIONS.MAP]: 
			events = map
		ACTION_STRINGS[ACTIONS.CAPTURE_MOUSE]: 
			events = capture_mouse
		ACTION_STRINGS[ACTIONS.RELEASE_MOUSE]: 
			events = release_mouse
	
	return events

#region File Management
func handle_loaded_file(file: ConfigFile) -> void:
	load_from_serialized(file)

	var remapped_controls := get_controls()
	save_to_input_map(remapped_controls)

func serialize() -> ConfigFile:
	var serialized_binds := {
		ACTION_STRINGS[ACTIONS.LEFT]: serialize_events(left),
		ACTION_STRINGS[ACTIONS.RIGHT]: serialize_events(right),
		ACTION_STRINGS[ACTIONS.UP]: serialize_events(up),
		ACTION_STRINGS[ACTIONS.DOWN]: serialize_events(down),
		ACTION_STRINGS[ACTIONS.LOOK_LEFT]: serialize_events(look_left),
		ACTION_STRINGS[ACTIONS.LOOK_RIGHT]: serialize_events(look_right),
		ACTION_STRINGS[ACTIONS.LOOK_UP]: serialize_events(look_up),
		ACTION_STRINGS[ACTIONS.LOOK_DOWN]: serialize_events(look_down),
		ACTION_STRINGS[ACTIONS.JUMP]: serialize_events(jump),
		ACTION_STRINGS[ACTIONS.SPRINT]: serialize_events(sprint),
		ACTION_STRINGS[ACTIONS.INTERACT]: serialize_events(interact),
		ACTION_STRINGS[ACTIONS.TOGGLE_FLIGHT]: serialize_events(toggle_flight),
		ACTION_STRINGS[ACTIONS.PAUSE]: serialize_events(pause),
		ACTION_STRINGS[ACTIONS.MAP]: serialize_events(map),
		ACTION_STRINGS[ACTIONS.CAPTURE_MOUSE]: serialize_events(capture_mouse),
		ACTION_STRINGS[ACTIONS.RELEASE_MOUSE]: serialize_events(release_mouse),
	}
	
	var config_file := ConfigFile.new()
	for bind in serialized_binds:
		config_file.set_value(INPUT_BINDS_SECTION, bind, serialized_binds[bind])
	
	return config_file


func load_from_serialized(config_file: ConfigFile) -> void:
	var left_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.LEFT])
	left = deserialize(left_config)
	var right_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.RIGHT])
	right = deserialize(right_config)
	var up_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.UP])
	up = deserialize(up_config)
	var down_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.DOWN])
	down = deserialize(down_config)
	var look_left_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.LOOK_LEFT])
	look_left = deserialize(look_left_config)
	var look_right_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.LOOK_RIGHT])
	look_right = deserialize(look_right_config)
	var look_up_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.LOOK_UP])
	look_up = deserialize(look_up_config)
	var look_down_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.LOOK_DOWN])
	look_down = deserialize(look_down_config)
	var jump_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.JUMP])
	jump = deserialize(jump_config)
	var sprint_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.SPRINT])
	sprint = deserialize(sprint_config)
	var interact_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.INTERACT])
	interact = deserialize(interact_config)
	var toggle_flight_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.TOGGLE_FLIGHT])
	toggle_flight = deserialize(toggle_flight_config)
	var pause_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.PAUSE])
	pause = deserialize(pause_config)
	var map_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.MAP])
	map = deserialize(map_config)
	var capture_mouse_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.CAPTURE_MOUSE])
	capture_mouse = deserialize(capture_mouse_config)
	var release_mouse_config: Array[Dictionary] = config_file.get_value(INPUT_BINDS_SECTION, ACTION_STRINGS[ACTIONS.RELEASE_MOUSE])
	release_mouse = deserialize(release_mouse_config)
#endregion File Management

#region InputEvent Serialization
# Add more to this as needed (eg. InputMouseMotion?)
enum INPUT_EVENT_TYPE { KEY, MOUSE_BUTTON, JOYPAD_BUTTON, JOYPAD_MOTION }

func deserialize(events: Array[Dictionary]) -> Array[InputEvent]:
	var deserialized_events: Array[InputEvent]
	for event in events:
		var deserialized_event := _deserialize_event(event)
		deserialized_events.append(deserialized_event)
	return deserialized_events

func serialize_events(events: Array[InputEvent]) -> Array[Dictionary]:
	var serialized_events: Array[Dictionary]
	for event in events:
		var serialized_event := _serialize_event(event)
		serialized_events.append(serialized_event)
	return serialized_events


func _serialize_event(event: InputEvent) -> Dictionary:
	var serialized_event: Dictionary = {}
	serialized_event["device"] = event.device
	
	# Keyboard
	if event is InputEventKey:
		serialized_event["type"] = INPUT_EVENT_TYPE.KEY
		serialized_event["pressed"] = event.pressed
		serialized_event["keycode"] = event.keycode
		serialized_event["physical_keycode"] = event.physical_keycode
		serialized_event["key_label"] = event.key_label
		serialized_event["unicode"] = event.unicode
		serialized_event["location"] = event.location
	
	# Mouse Button
	elif event is InputEventMouseButton:
		serialized_event["type"] = INPUT_EVENT_TYPE.MOUSE_BUTTON
		serialized_event["button_index"] = event.button_index
		serialized_event["double_click"] = event.double_click
		serialized_event["pressed"] = event.pressed
		serialized_event["button_mask"] = event.button_mask
	
	# Controller Button
	elif event is InputEventJoypadButton:
		serialized_event["type"] = INPUT_EVENT_TYPE.JOYPAD_BUTTON
		serialized_event["button_index"] = event.button_index
		serialized_event["pressed"] = event.pressed
	
	# Controller Motion (eg. joystick or analog triggers)
	elif event is InputEventJoypadMotion:
		serialized_event["type"] = INPUT_EVENT_TYPE.JOYPAD_MOTION
		serialized_event["axis"] = event.axis
		serialized_event["axis_value"] = event.axis_value
	
	return serialized_event

func _deserialize_event(event: Dictionary) -> InputEvent:
	var new_event: InputEvent
	match event["type"]:
		# Keyboard
		INPUT_EVENT_TYPE.KEY:
			new_event = InputEventKey.new()
			new_event.pressed = event["pressed"]
			new_event.keycode = event["keycode"]
			new_event.physical_keycode = event["physical_keycode"]
			new_event.key_label = event["key_label"]
			new_event.unicode = event["unicode"]
			new_event.location = event["location"]
		
		# Mouse Button
		INPUT_EVENT_TYPE.MOUSE_BUTTON:
			new_event = InputEventMouseButton.new()
			new_event.button_index = event["button_index"]
			new_event.double_click = event["double_click"]
			new_event.pressed = event["pressed"]
			new_event.button_mask = event["button_mask"]
		
		# Controller Button
		INPUT_EVENT_TYPE.JOYPAD_BUTTON:
			new_event = InputEventJoypadButton.new()
			new_event.button_index = event["button_index"]
			new_event.pressed = event["pressed"]
		
		# Controller Motion (eg. joystick or analog triggers)
		INPUT_EVENT_TYPE.JOYPAD_MOTION:
			new_event = InputEventJoypadMotion.new()
			new_event.axis = event["axis"]
			new_event.axis_value = event["axis_value"]
		
		# Default - unrecognized event
		_:
			printerr("[InputBinds] Attempted to deserialize an unrecognized event! Event=", event)
	
	return new_event
#endregion InputEvent Serialization
