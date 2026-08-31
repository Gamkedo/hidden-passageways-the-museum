extends Control

@onready var text_on_panel = $Background/Text

func show_text(text: String):
	text_on_panel.text = text
	show()

func _on_close_button_pressed() -> void:
	hide()
