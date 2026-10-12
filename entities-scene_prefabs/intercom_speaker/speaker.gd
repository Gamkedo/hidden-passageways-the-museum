extends StaticBody3D

var stream_nearby: AudioStream = null
@onready var speaker_interactable = $SpeakerInteractable

func _ready() -> void:
	speaker_interactable.interaction_complete.connect(_on_speaker_interact)

func _on_speaker_interact():
	IntercomAudioManager.play_game_ost(stream_nearby)

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
