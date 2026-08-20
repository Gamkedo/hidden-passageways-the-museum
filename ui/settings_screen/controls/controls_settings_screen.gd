class_name InputBindsScreen
extends PanelContainer

signal reset_binds

const INPUT_BINDS: InputBinds = preload("uid://dnfis17edcjtb")
const CONTROLLER_ICON_ACTION_MAP: ControllerIconActionMap = preload("uid://b0v8pfiulviyt")

#region Mouse & Keyboard
@onready var k_move_left_input_change: Button = %KMoveLeftInputChange
@onready var k_move_right_input_change: Button = %KMoveRightInputChange
@onready var k_move_forward_input_change: Button = %KMoveForwardInputChange
@onready var k_move_backward_input_change: Button = %KMoveBackwardInputChange
@onready var k_jump_input_change: Button = %KJumpInputChange
@onready var k_interact_input_change: Button = %KInteractInputChange
@onready var k_sprint_input_change: Button = %KSprintInputChange
@onready var k_toggle_flight_input_change: Button = %KToggleFlightInputChange
@onready var k_pause_input_change: Button = %KPauseInputChange
@onready var k_map_input_change: Button = %KMapInputChange
@onready var capture_mouse_input_change: Button = %CaptureMouseInputChange
@onready var release_mouse_input_change: Button = %ReleaseMouseInputChange
#endregion Mouse & Keyboard

#region Controller
@onready var c_move_left_input_change: Button = %CMoveLeftInputChange
@onready var c_move_right_input_change: Button = %CMoveRightInputChange
@onready var c_move_forward_input_change: Button = %CMoveForwardInputChange
@onready var c_move_backward_input_change: Button = %CMoveBackwardInputChange
@onready var c_jump_input_change: Button = %CJumpInputChange
@onready var c_interact_input_change: Button = %CInteractInputChange
@onready var c_sprint_input_change: Button = %CSprintInputChange
@onready var c_toggle_flight_input_change: Button = %CToggleFlightInputChange
@onready var c_pause_input_change: Button = %CPauseInputChange
@onready var c_map_input_change: Button = %CMapInputChange
#endregion Controller

@onready var reset_binds_button: Button = %ResetBinds

#region Input Change Prompt
@onready var input_record_overlay: PanelContainer = %InputRecordOverlay
@onready var input_display_hint: Label = %InputDisplayHint
@onready var confirm_new_input_button: Button = %ConfirmNewInputButton
#endregion Input Change Prompt

@onready var MOUSE_AND_KEYBOARD_ACTION_MAP: Dictionary[Button, InputBinds.ACTIONS] = {
	# M&K
	k_move_left_input_change: InputBinds.ACTIONS.LEFT,
	k_move_right_input_change: InputBinds.ACTIONS.RIGHT,
	k_move_forward_input_change: InputBinds.ACTIONS.UP,
	k_move_backward_input_change: InputBinds.ACTIONS.DOWN,
	k_jump_input_change: InputBinds.ACTIONS.JUMP,
	k_interact_input_change: InputBinds.ACTIONS.INTERACT,
	k_sprint_input_change: InputBinds.ACTIONS.SPRINT,
	k_toggle_flight_input_change: InputBinds.ACTIONS.TOGGLE_FLIGHT,
	k_pause_input_change: InputBinds.ACTIONS.PAUSE,
	k_map_input_change: InputBinds.ACTIONS.MAP,
	capture_mouse_input_change: InputBinds.ACTIONS.CAPTURE_MOUSE,
	release_mouse_input_change: InputBinds.ACTIONS.RELEASE_MOUSE,
}
@onready var CONTROLLER_ACTION_MAP: Dictionary[Button, InputBinds.ACTIONS] = {
	# Controller
	c_move_left_input_change: InputBinds.ACTIONS.LEFT,
	c_move_right_input_change: InputBinds.ACTIONS.RIGHT,
	c_move_forward_input_change: InputBinds.ACTIONS.UP,
	c_move_backward_input_change: InputBinds.ACTIONS.DOWN,
	c_jump_input_change: InputBinds.ACTIONS.JUMP,
	c_interact_input_change: InputBinds.ACTIONS.INTERACT,
	c_sprint_input_change: InputBinds.ACTIONS.SPRINT,
	c_toggle_flight_input_change: InputBinds.ACTIONS.TOGGLE_FLIGHT,
	c_pause_input_change: InputBinds.ACTIONS.PAUSE,
	c_map_input_change: InputBinds.ACTIONS.MAP,
}

var target_input_change_button: Button
var target_input_method: InputBinds.INPUT_METHOD
var recorded_change_input: InputEvent


func save_input_to_settings(action_name: StringName, input_event: InputEvent) -> void:
	if input_event != null:
		INPUT_BINDS.remap_event_in_input_map(action_name, input_event)

#region Input Change Prompt
func process_input_change_event(event: InputEvent) -> void:
	recorded_change_input = event
	input_display_hint.text = event.as_text()

func display_input_change_prompt(action_name: StringName, method: InputBinds.INPUT_METHOD) -> void:
	var action_events := InputMap.action_get_events(action_name)
	var matching_events := action_events.filter(func(event):
		if method == InputBinds.INPUT_METHOD.MOUSE_AND_KEYBOARD and event is InputEventKey:
			return true
		elif method == InputBinds.INPUT_METHOD.CONTROLLER and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			return true
		# Not matching
		return false
	)
	
	# If there's ever more than one something isn't right...
	var first_event: InputEvent = matching_events[0]
	var action_text := first_event.as_text()
	input_display_hint.text = action_text
	
	input_record_overlay.show()

func hide_input_change_prompt() -> void:
	input_record_overlay.hide()
#endregion Input Change Prompt

func _on_input_change_button_pressed(target_button: Button, method: InputBinds.INPUT_METHOD) -> void:
	target_input_change_button = target_button
	target_input_method = method
	var target_action_name := _get_action_name_from_button(target_button, method)
	display_input_change_prompt(target_action_name, method)

func connect_input_change_button_signals() -> void:
	# Keys for this dictionary are the buttons themselves
	for mnk_button in MOUSE_AND_KEYBOARD_ACTION_MAP:
		mnk_button.pressed.connect(_on_input_change_button_pressed.bind(mnk_button, InputBinds.INPUT_METHOD.MOUSE_AND_KEYBOARD))
	for controller_button in CONTROLLER_ACTION_MAP:
		controller_button.pressed.connect(_on_input_change_button_pressed.bind(controller_button, InputBinds.INPUT_METHOD.CONTROLLER))

func _on_confirm_new_input_button_pressed() -> void:
	var target_action_name := _get_action_name_from_button(target_input_change_button, target_input_method)
	save_input_to_settings(target_action_name, recorded_change_input)
	_update_display_for_button(target_input_change_button)
	#target_input_change_button.text = recorded_change_input.as_text()
	
	target_input_change_button = null
	target_input_method = InputBinds.INPUT_METHOD.NONE
	recorded_change_input = null
	hide_input_change_prompt()

func _get_action_name_from_button(target_button: Button, method: InputBinds.INPUT_METHOD) -> StringName:
	var target_action_key: int
	if method == InputBinds.INPUT_METHOD.MOUSE_AND_KEYBOARD:
		target_action_key = MOUSE_AND_KEYBOARD_ACTION_MAP[target_button]
	elif method == InputBinds.INPUT_METHOD.CONTROLLER:
		target_action_key = CONTROLLER_ACTION_MAP[target_button]
	var target_action_name := InputBinds.ACTION_STRINGS[target_action_key]
	return target_action_name

func _get_action_from_button(target_button: Button, method: InputBinds.INPUT_METHOD) -> InputEvent:
	var action_name := _get_action_name_from_button(target_button, method)
	var action_events := InputMap.action_get_events(action_name)
	var matching_events := action_events.filter(func(event):
		if method == InputBinds.INPUT_METHOD.MOUSE_AND_KEYBOARD and (event is InputEventKey or event is InputEventMouse):
			return true
		elif method == InputBinds.INPUT_METHOD.CONTROLLER and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			return true
		# Not matching
		return false
	)
	# If there's ever more (or less) than one something isn't right...
	var first_event: InputEvent = matching_events[0]
	return first_event

func _get_action_text_from_button(target_button: Button, method: InputBinds.INPUT_METHOD) -> String:
	var action_event := _get_action_from_button(target_button, method)
	var action_text := action_event.as_text()
	return action_text

func _load_input_change_button_displays() -> void:
	for mnk_button: Button in MOUSE_AND_KEYBOARD_ACTION_MAP:
		_update_display_for_button(mnk_button)
	for controller_button: Button in CONTROLLER_ACTION_MAP:
		_update_display_for_button(controller_button)

func _update_display_for_button(button: Button) -> void:
	if MOUSE_AND_KEYBOARD_ACTION_MAP.has(button):
		# TODO: Add M&K icon action map
		#var button_action := _get_action_from_button(button, InputBinds.INPUT_METHOD.MOUSE_AND_KEYBOARD)
		var action_text := _get_action_text_from_button(button, InputBinds.INPUT_METHOD.MOUSE_AND_KEYBOARD)
		button.text = action_text
	elif CONTROLLER_ACTION_MAP.has(button):
		var button_action := _get_action_from_button(button, InputBinds.INPUT_METHOD.CONTROLLER)
		var controller_action_icon := CONTROLLER_ICON_ACTION_MAP.get_icon_for_event(button_action)
		if controller_action_icon != null:
			button.icon = controller_action_icon
			button.text = ""
		else:
			var action_text := _get_action_text_from_button(button, InputBinds.INPUT_METHOD.CONTROLLER)
			button.text = action_text
			button.icon = null


func _on_input_map_updated() -> void:
	_load_input_change_button_displays()

func _on_reset_binds_pressed() -> void:
	SettingsManager.reset_binds_to_default()
	reset_binds.emit()

func _ready() -> void:
	connect_input_change_button_signals()
	confirm_new_input_button.pressed.connect(_on_confirm_new_input_button_pressed)
	reset_binds_button.pressed.connect(_on_reset_binds_pressed)
	_load_input_change_button_displays()
	INPUT_BINDS.input_map_updated.connect(_on_input_map_updated)
	hide_input_change_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if input_record_overlay.visible: # Lazy flag
		process_input_change_event(event)
