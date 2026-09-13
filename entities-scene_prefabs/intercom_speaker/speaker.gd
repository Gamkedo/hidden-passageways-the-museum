extends StaticBody3D

var stream_list: Array[AudioStream] = []
var current_stream_index = -1
@onready var speaker_interactable = $SpeakerInteractable

func _ready() -> void:
	speaker_interactable.interaction_complete.connect(_on_speaker_interact)

func _on_speaker_interact():
	current_stream_index = (current_stream_index + 1) % stream_list.size()
	IntercomAudioManager.play_game_ost(stream_list[current_stream_index])

#func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.is_pressed():
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#
	#pass # Replace with function body.
#
#
#func _on_mouse_entered() -> void:
	#print("mouse over speaker")
	#pass # Replace with function body.
