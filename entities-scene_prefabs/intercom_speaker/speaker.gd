extends StaticBody3D

@export var stream_list: Array[AudioStream] = []
var current_stream_index = 0

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_stream_index = current_stream_index + 1 % stream_list.size()
			IntercomAudioManager.play_game_ost(stream_list[current_stream_index])
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	print("mouse over speaker")
	pass # Replace with function body.
