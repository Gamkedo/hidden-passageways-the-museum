extends StaticBody3D

@export_file("*.tscn")
var goto_scene := ""

func open_scene():
	print("Changing scene (did file change?) to:", goto_scene)
	get_tree().change_scene_to_file(goto_scene)
