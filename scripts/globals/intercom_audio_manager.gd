extends Node

@onready var global_stream_player = $GlobalStreamPlayer
@onready var game_stream_player = $GameStreamPlayer

@export var global_stream_source: AudioStream

func _ready() -> void:
	global_stream_player.stream = global_stream_source
	global_stream_player.play()

func play_game_ost(source):
	game_stream_player.stream = source
	game_stream_player.play()

func stop_game_ost():
	game_stream_player.stop()
