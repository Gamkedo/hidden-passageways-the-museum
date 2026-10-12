extends Node

@onready var global_stream_player = $GlobalStreamPlayer
@onready var game_stream_player = $GameStreamPlayer

@export var global_stream_source: AudioStream
var global_stream_position := 0.0
var temporary_ost_active := false

func _ready() -> void:
	global_stream_player.stream = global_stream_source
	global_stream_player.play()
	game_stream_player.finished.connect(stop_game_ost)

func start_playing_song(source):
	if not global_stream_player.stream_paused:
		var tween = create_tween()
		tween.tween_property(global_stream_player, "volume_db", -100.0, 1.0).set_ease(Tween.EASE_OUT)
		tween.finished.connect(func():
			global_stream_player.stream_paused = true
		)
	game_stream_player.stop()
	game_stream_player.stream = source
	game_stream_player.play()

func play_temporary_ost(source):
	if source == null:
		print("play_game_ost bailed on null source")
		return

	if not temporary_ost_active:
		global_stream_position = global_stream_player.get_playback_position()
		temporary_ost_active = true

	start_playing_song(source)

func restore_previous_ost():
	if not temporary_ost_active:
		return

	game_stream_player.stop()

	global_stream_player.stream_paused = false
	global_stream_player.play(global_stream_position)

	var tween = create_tween()
	tween.tween_property(
        global_stream_player, "volume_db", -10.0, 2.0
    ).set_ease(Tween.EASE_OUT)

	temporary_ost_active = false

func stop_game_ost():
	global_stream_player.stream_paused = false
	var tween = create_tween()
	tween.tween_property(global_stream_player, "volume_db", -10.0, 2.0).set_ease(Tween.EASE_OUT)
	game_stream_player.stop()
