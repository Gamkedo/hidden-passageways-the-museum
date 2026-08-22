class_name MouseAndKeyboardIconActionMap
extends IconActionMap


@export_group("Mouse")
@export var left_click: Dictionary[InputEventMouseButton, Texture2D]
@export var right_click: Dictionary[InputEventMouseButton, Texture2D]
@export var middle_click: Dictionary[InputEventMouseButton, Texture2D]
@export var scroll_up: Dictionary[InputEventMouseButton, Texture2D]
@export var scroll_down: Dictionary[InputEventMouseButton, Texture2D]


 #Get all mappings as a single dictionary
func _get_all_icon_mappings() -> Dictionary[InputEvent, Texture2D]:
	var all_mappings := [
		left_click,
		right_click,
		middle_click,
		scroll_up,
		scroll_down,
	]
	
	var icon_mappings: Dictionary[InputEvent, Texture2D] = {}
	for mapping in all_mappings:
		icon_mappings.merge(mapping)
	return icon_mappings
