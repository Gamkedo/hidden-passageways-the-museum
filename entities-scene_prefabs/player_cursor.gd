class_name PlayerCursor
extends Control

@onready var cursor_label: Label = %CursorLabel
@onready var cursor_progress_bar: TextureProgressBar = %CursorProgressBar

var default_cursor_text: String = "+"
var default_cursor_texture: Texture2D

## Display the given texture as a progress bar texture.
## Use @text to display an input hint. If not provided, the text cursor will be hidden.
func display_cursor_texture(texture: Texture2D, text: String = "") -> void:
	if text == "":
		cursor_label.hide()
	else:
		cursor_label.text = text
		cursor_label.show()
	
	cursor_progress_bar.texture_under = texture
	cursor_progress_bar.show()

func display_default_cursor_texture() -> void:
	cursor_progress_bar.texture_under = default_cursor_texture
	cursor_progress_bar.texture_progress = default_cursor_texture
	

func display_default_cursor() -> void:
	cursor_label.text = default_cursor_text
	cursor_label.show()
	cursor_progress_bar.hide()


func set_cursor_progress(current_progress: float, max_progress: float) -> void:
	var target_value := current_progress
	var target_max := max_progress
	# If they are the same, show an "empty" progress bar
	if target_value == target_max:
		target_value = 0
		target_max = 1
	cursor_progress_bar.value = target_value
	cursor_progress_bar.max_value = target_max

func _ready() -> void:
	if cursor_label.text != "":
		default_cursor_text = cursor_label.text
	if cursor_progress_bar.texture_under != null:
		default_cursor_texture = cursor_progress_bar.texture_under
	display_default_cursor()
