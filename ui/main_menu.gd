extends Control

@export_file("*.tscn")
var play_game_scene:String

func _on_play_pressed() -> void:
	if play_game_scene:
		SceneManager.change_scene_to_file(play_game_scene)
