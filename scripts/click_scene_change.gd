extends StaticBody3D

@export_file("*.tscn")
var goto_scene: String = ""

func open_scene():
	if goto_scene.is_empty():
		push_warning("Empty goto_scene property for click_scene_change.gd node. Configure in Inspector.")
		return
	
	print("Changing scene (did file change?) to:", goto_scene)
	SceneManager.change_scene_to_file(goto_scene)
