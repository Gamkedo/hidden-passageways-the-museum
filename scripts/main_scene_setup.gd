extends Node

func _ready() -> void:
	MenuManager.set_pause_screen_enabled(true)
	# remove any contained tscn area player test controllers/lighting
	for node in get_tree().get_nodes_in_group("EditorQuickTestGroup"):
		# print("removed EditorQuickTestGroup (expected unless testing scene that's normally part of main scene)")
		node.queue_free()
