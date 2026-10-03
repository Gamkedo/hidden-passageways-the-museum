class_name SettingsScreen
extends PanelContainer

## Set to 'false' to hide the heading label (eg. for when inside a TabContainer)
@export var show_heading: bool = true

@onready var tab_container: TabContainer = %TabContainer
@onready var input_settings_screen: InputSettingsScreen = %InputSettingsScreen
@onready var controls_screen: InputBindsScreen = %ControlsScreen

var first_screen: SettingsTabContainer
var last_focused: Control

func focus_first_input() -> void:
	tab_container.current_tab = 0
	_focus_first_input_in_container(first_screen)

func go_to_next_tab() -> void:
	var next_tab_index := clampi(tab_container.current_tab + 1, 0, tab_container.get_child_count() - 1)
	tab_container.current_tab = next_tab_index
	var current_container := tab_container.get_child(tab_container.current_tab)
	_focus_first_input_in_container(current_container)

func go_to_previous_tab() -> void:
	var previous_tab_index := clampi(tab_container.current_tab - 1, 0, tab_container.get_child_count() - 1)
	tab_container.current_tab = previous_tab_index
	var current_container := tab_container.get_child(tab_container.current_tab)
	_focus_first_input_in_container(current_container)


func _focus_first_input_in_container(container: SettingsTabContainer) -> void:
	container.focus_first_input()
	var input_controls := container.get_child_inputs()
	var first_input := input_controls[0]
	first_input.grab_focus()


func _ready() -> void:
	first_screen = tab_container.get_child(0)

func _input(event: InputEvent) -> void:
	if !visible:
		return
	# These are intentionally "hard-coded" input events because these are "menu"
	# inputs, not "gameplay" inputs. That isn't to say they should never be
	# extracted to the rest of the InputSettings code, but I'm too lazy to
	# right now since they don't really need remapping support yet :)
	if Input.is_action_just_pressed_by_event("ui_next_tab", event):
		go_to_next_tab()
	elif Input.is_action_just_pressed_by_event("ui_previous_tab", event):
		go_to_previous_tab()
