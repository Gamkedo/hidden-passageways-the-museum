class_name PauseScreen
extends Control

const MAIN_MENU = preload("uid://dcd1kode5ypff")

@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

var last_focused: PauseScreenButton

func display_pause_screen() -> void:
	pass

func resume_game() -> void:
	pass

func display_settings() -> void:
	pass

func go_to_main_menu() -> void:
	# TODO: Use a global class/handler for this
	get_tree().change_scene_to_packed(MAIN_MENU)

func quit_game() -> void:
	# TODO: Call a function/signal to a general or global handler to quit game
	get_tree().quit()


func _connect_button_signals() -> void:
	resume_button.pressed.connect(resume_game)
	resume_button.mouse_exited.connect(_on_mouse_exited_button)
	
	settings_button.pressed.connect(display_settings)
	settings_button.mouse_exited.connect(_on_mouse_exited_button)
	
	main_menu_button.pressed.connect(go_to_main_menu)
	main_menu_button.mouse_exited.connect(_on_mouse_exited_button)
	
	quit_button.pressed.connect(quit_game)
	quit_button.mouse_exited.connect(_on_mouse_exited_button)


func _ready() -> void:
	_connect_button_signals()
	resume_button.grab_focus()

func _on_mouse_exited_button() -> void:
	last_focused = get_viewport().gui_get_focus_owner()


func _input(event: InputEvent) -> void:
	var menu_inputs := ["ui_up", "ui_down", "ui_left", "ui_right"]
	var menu_input_pressed := menu_inputs.any(func(input): return Input.is_action_just_pressed_by_event(input, event))
	var current_focus := get_viewport().gui_get_focus_owner()
	if menu_input_pressed and current_focus == null:
		last_focused.grab_focus()
		get_viewport().set_input_as_handled()
