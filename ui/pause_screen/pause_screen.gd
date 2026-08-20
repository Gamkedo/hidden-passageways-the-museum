class_name PauseScreen
extends Control

signal close_pause_screen
signal go_to_main_menu
signal quit_game

# Buttons
@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

# Menus
## Used for navigating "back" from sub-menus to the pause screen
@onready var back_button: Button = %BackButton
@onready var screen_tab_container: TabContainer = %ScreenTabContainer
@onready var main_pause_screen: MarginContainer = %MainPauseScreen
@onready var settings_screen: SettingsScreen = %SettingsScreen

var last_focused: PauseScreenButton

func display_pause_screen() -> void:
	show()
	display_pause_menu()

#region Buttons
func resume_game() -> void:
	close_pause_screen.emit()

func display_pause_menu() -> void:
	_set_displayed_screen(main_pause_screen)
	resume_button.grab_focus.call_deferred()

func display_settings() -> void:
	_set_displayed_screen(settings_screen)

func _set_displayed_screen(screen: Control) -> void:
	var screen_index := screen.get_index()
	screen_tab_container.current_tab = screen_index
	
	back_button.visible = screen_index != 0

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
	
	back_button.pressed.connect(display_pause_menu)


func _ready() -> void:
	_connect_button_signals()
	
	back_button.hide()


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
