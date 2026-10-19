class_name PageTextPanel
extends Control

var displaying_now: bool = false
@onready var text_on_panel = $Background/Text

func show_text(text: String):
	text_on_panel.text = text
	show()
	displaying_now = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_close_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	displaying_now = false
	hide()
