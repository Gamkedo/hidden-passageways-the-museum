class_name PauseScreen
extends Control

signal close_pause_screen
signal go_to_main_menu
signal quit_game

@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

var last_focused: PauseScreenButton

func display_pause_screen() -> void:
	show()

#region Buttons
func resume_game() -> void:
	close_pause_screen.emit()

func display_settings() -> void:
	# TODO: Create a separate "Settings" screen and instance one within the pause screen
	# Then manage displaying it within this file
	pass

func main_menu() -> void:
	go_to_main_menu.emit()

func quit() -> void:
	quit_game.emit()
#endregion Buttons

func _connect_button_signals() -> void:
	resume_button.pressed.connect(resume_game)
	resume_button.mouse_exited.connect(_on_mouse_exited_button)
	
	settings_button.pressed.connect(display_settings)
	settings_button.mouse_exited.connect(_on_mouse_exited_button)
	
	main_menu_button.pressed.connect(main_menu)
	main_menu_button.mouse_exited.connect(_on_mouse_exited_button)
	
	quit_button.pressed.connect(quit)
	quit_button.mouse_exited.connect(_on_mouse_exited_button)


func _ready() -> void:
	_connect_button_signals()
	resume_button.grab_focus()


func _on_mouse_exited_button() -> void:
	last_focused = get_viewport().gui_get_focus_owner()

# This lets a menu input re-focus to the last focused UI node
# eg. Mouse hover over a button -> menu input on a controller
func _input(event: InputEvent) -> void:
	var menu_inputs := ["ui_up", "ui_down", "ui_left", "ui_right"]
	var menu_input_pressed := menu_inputs.any(func(input): return Input.is_action_just_pressed_by_event(input, event))
	var current_focus := get_viewport().gui_get_focus_owner()
	if menu_input_pressed and current_focus == null and last_focused != null:
		last_focused.grab_focus()
		# Prevent the input from also navigating up/down
		get_viewport().set_input_as_handled()
