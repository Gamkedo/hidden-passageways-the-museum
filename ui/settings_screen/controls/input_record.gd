class_name InputRecord
extends PanelContainer

signal input_recorded(event: InputEvent)
signal input_confirmed(event: InputEvent)
signal canceled

@onready var input_record_heading: Label = %InputRecordHeading
@onready var input_display_hint: Button = %InputDisplayHint
@onready var confirm_new_input_button: Button = %ConfirmNewInputButton
@onready var cancel_button: Button = %CancelButton

const CONTROLLER_ICON_ACTION_MAP: ControllerIconActionMap = preload("uid://b0v8pfiulviyt")
const MOUSE_AND_KEYBOARD_ICON_ACTION_MAP: MouseAndKeyboardIconActionMap = preload("uid://duqfhuqxn0yhc")

var recorded_change_input: InputEvent


#region Input Change Prompt
func process_input_change_event(event: InputEvent) -> void:
	recorded_change_input = event
	set_display_hint_for_event(event)
	if input_display_hint.has_focus() and not confirm_new_input_button.has_focus():
		confirm_new_input_button.grab_focus.call_deferred()
	input_recorded.emit(event)

func display_prompt(action_name: StringName, method: InputBinds.INPUT_METHOD) -> void:
	var action_events := InputMap.action_get_events(action_name)
	var matching_events := action_events.filter(func(event: InputEvent) -> bool:
		if method == InputBinds.INPUT_METHOD.MOUSE_AND_KEYBOARD and event is InputEventKey:
			return true
		elif method == InputBinds.INPUT_METHOD.CONTROLLER and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			return true
		# Not matching
		return false
	)
	
	# If there's ever more than one something isn't right...
	var first_event: InputEvent = matching_events[0]
	set_display_hint_for_event(first_event)
	input_display_hint.grab_focus.call_deferred()

func set_display_hint_for_event(event: InputEvent) -> void:
	var mapped_texture: Texture2D = null
	if event is InputEventMouseButton or event is InputEventKey:
		mapped_texture = MOUSE_AND_KEYBOARD_ICON_ACTION_MAP.get_icon_for_event(event)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		mapped_texture = CONTROLLER_ICON_ACTION_MAP.get_icon_for_event(event)
	
	if mapped_texture is Texture2D:
		input_display_hint.icon = mapped_texture
		input_display_hint.text = ""
	else:
		var action_text := event.as_text()
		input_display_hint.text = action_text
		input_display_hint.icon = null
#endregion Input Change Prompt


func _on_confirm_button_pressed() -> void:
	accept_event()
	input_confirmed.emit(recorded_change_input)

func _on_cancel_button_pressed() -> void:
	accept_event()
	canceled.emit()

func _input(event: InputEvent) -> void:
	if _should_record_event(event):
		process_input_change_event(event)

func _should_record_event(event: InputEvent) -> bool:
	# Ignore "on release" events
	if event.is_released():
		return false
	
	# Ignore mouse motions
	if event is InputEventMouseMotion:
		return false
	
	# Always record if the display hint is explicitly focused
	if input_display_hint.has_focus():
		return true
	
	# Don't record when trying to confirm the input change
	var ui_actions := [
		"ui_accept",
		"ui_up", "ui_down", "ui_left", "ui_right",
		"ui_focus_next", "ui_focus_prev"
	]
	var is_ui_action := ui_actions.any(func(action_name: String):
		return event.is_action(action_name)
	)
	# For joystick navigation, require a minimum threshold to record an actual input
	if event is InputEventJoypadMotion:
		var joystick_strength := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if is_ui_action and joystick_strength.length() < 0.8:
			return false
	if is_ui_action and not input_display_hint.has_focus():
		return false
	
	
	# Ignore mouse clicks on buttons that match the button masks (bitwise)
	var ignore_buttons: Array[Button] = [confirm_new_input_button, cancel_button]
	for button in ignore_buttons:
		if event is InputEventMouseButton and button.is_hovered():
			# This assumes the MouseButton enum lines up with the mask (defined by Godot)
			var event_matches_mask: int = event.button_index & button.button_mask
			if event_matches_mask > 0: # Event matches mask
				return false
	
	return true

func _ready() -> void:
	confirm_new_input_button.pressed.connect(_on_confirm_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
