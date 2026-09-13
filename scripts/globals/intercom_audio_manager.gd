extends Node

@onready var global_stream_player = $GlobalStreamPlayer
@onready var game_stream_player = $GameStreamPlayer

@export var global_stream_source: AudioStream

func _ready() -> void:
	global_stream_player.stream = global_stream_source
	global_stream_player.play()
	game_stream_player.finished.connect(stop_game_ost)

func play_game_ost(source):
	if not global_stream_player.stream_paused:
		var tween = create_tween()
		tween.tween_property(global_stream_player, "volume_db", -100.0, 1.0).set_ease(Tween.EASE_OUT)
		tween.finished.connect(func():
			global_stream_player.stream_paused = true
		)
	game_stream_player.stop()
	game_stream_player.stream = source
	game_stream_player.play()

func stop_game_ost():
	global_stream_player.stream_paused = false
	var tween = create_tween()
	tween.tween_property(global_stream_player, "volume_db", -10.0, 2.0).set_ease(Tween.EASE_OUT)
	game_stream_player.stop()
