extends Node

@onready var global_stream_player = $GlobalStreamPlayer
@onready var game_stream_player = $GameStreamPlayer

@export var global_stream_source: AudioStream
var global_stream_position := 0.0
var temporary_ost_active := false

# adding these to fix music being stuck if I run through speakers mid fade
var main_muzak_fade: Tween
var local_speaker_fade: Tween

func _ready() -> void:
	global_stream_player.stream = global_stream_source
	global_stream_player.play()
	game_stream_player.finished.connect(stop_game_ost)

func start_playing_song(source):
	if not global_stream_player.stream_paused:
		if main_muzak_fade and main_muzak_fade.is_running():
			main_muzak_fade.kill()
		main_muzak_fade = create_tween()
		main_muzak_fade.tween_property(global_stream_player, "volume_db", -100.0, 1.0).set_ease(Tween.EASE_OUT)
		main_muzak_fade.finished.connect(func():
			global_stream_player.stream_paused = true
		)
	game_stream_player.stop()
	game_stream_player.volume_db = -80.0
	game_stream_player.stream = source
	game_stream_player.play()
	
	if local_speaker_fade and local_speaker_fade.is_running():
		local_speaker_fade.kill()
	
	local_speaker_fade = create_tween()
	local_speaker_fade.tween_property(game_stream_player, "volume_db", 0.0, 1.0)

func global_pause_music(): # added for clicking button to open new game tab
	# game_stream_player.stop() # tripped restore_previous_ost starting main song
	game_stream_player.volume_db = -100.0 # so instead silencing volume

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
		
	if local_speaker_fade and local_speaker_fade.is_running():
		local_speaker_fade.kill()

	if main_muzak_fade and main_muzak_fade.is_running():
		main_muzak_fade.kill()

	local_speaker_fade = create_tween()
	local_speaker_fade.tween_property(game_stream_player, "volume_db", -80.0, 1.0)

	global_stream_player.stream_paused = false
	global_stream_player.play(global_stream_position)

	main_muzak_fade = create_tween()
	main_muzak_fade.tween_property(global_stream_player, "volume_db", 0.0, 1.0).set_ease(Tween.EASE_OUT)
	main_muzak_fade.finished.connect(no_longer_playing_ost)

func no_longer_playing_ost():
	temporary_ost_active = false

func stop_game_ost():
	restore_previous_ost()
