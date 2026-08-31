extends Control

@onready var text_on_panel = $Background/Text

func show_text(text: String):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	text_on_panel.text = text
	show()

func _on_close_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()
