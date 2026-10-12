extends StaticBody3D

var stream_nearby: AudioStream = null
@onready var speaker_interactable = $SpeakerInteractable

@onready var autoplay_trigger: Area3D = $MusicAutoplayBox

func _ready() -> void:
	speaker_interactable.interaction_complete.connect(_on_speaker_interact)
	autoplay_trigger.body_entered.connect(_on_trigger_entered)
	autoplay_trigger.body_exited.connect(_on_trigger_exited)

func _on_speaker_interact():
	IntercomAudioManager.play_temporary_ost(stream_nearby)
	
func _on_trigger_entered(body):
	print("Entered body: ", body.name, " | Groups: ", body.get_groups())
	if body.is_in_group("Player"):
		print("auto playing song")
		IntercomAudioManager.play_temporary_ost(stream_nearby)

func _on_trigger_exited(body):
	if body.is_in_group("Player"):
		print("auto stopping song")
		IntercomAudioManager.restore_previous_ost()
