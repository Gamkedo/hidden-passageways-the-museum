# MenuManager
extends Node

@export var pause_screen_enabled: bool = false:
	set = set_pause_screen_enabled

@onready var pause_screen_layer: CanvasLayer = %PauseScreenLayer
@onready var pause_screen: PauseScreen = %PauseScreen

const MAIN_MENU = preload("uid://dcd1kode5ypff")

func _ready() -> void:
	hide_pause_screen(false)
	pause_screen.close_pause_screen.connect(hide_pause_screen)
	pause_screen.go_to_main_menu.connect(go_to_main_menu)
	pause_screen.quit_game.connect(quit_game)

func set_pause_screen_enabled(enable: bool) -> void:
	pause_screen_enabled = enable
	if not enable:
		# Assume that "disabling" the pause screen also should "hide" it
		hide_pause_screen(false)


func attempt_toggle_pause_screen() -> void:
	if pause_screen_layer.visible:
		hide_pause_screen()
	else:
		display_pause_screen()

func display_pause_screen() -> void:
	if pause_screen_enabled:
		pause_screen_layer.show()
		pause_screen.display_pause_screen()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true # TODO: Probably should have a global GameManager handle this


# Always hide regardless of the "enabled" flag
# in case we try to "disable" it and then "hide" it
func hide_pause_screen(capture_mouse: bool = true) -> void:
	pause_screen_layer.hide()
	# TODO: Probably should have a global GameManager handle this
	get_tree().paused = false
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func go_to_main_menu() -> void:
	# TODO: Use a global class/handler for this
	hide_pause_screen(false)
	get_tree().change_scene_to_packed(MAIN_MENU)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func quit_game() -> void:
	# TODO: Call a function/signal to a general or global handler to quit game
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed_by_event("pause", event):
		attempt_toggle_pause_screen()
