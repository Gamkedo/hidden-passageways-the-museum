extends Node

const MAIN = preload("uid://baos2k6gymk8n")

## TODO you can add a loading screen here.

func _on_precompilation_main_finished() -> void:
	SceneManager.change_scene_to_packed(
		MAIN
	)
