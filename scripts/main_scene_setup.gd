extends Node

func _ready() -> void:
	# remove any contained tscn area player test controllers/lighting
	for node in get_tree().get_nodes_in_group("EditorQuickTestGroup"):
		print("removed one")
		node.queue_free()
