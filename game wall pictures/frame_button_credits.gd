extends StaticBody3D

@export_multiline var game_label: String = ""
@export var button_link: String = ""
@export var world_scene: String = ""
@export_multiline var credits: String = ""

func _ready() -> void:
	var button_label = get_node("Button Game/GameLabel") as Label3D
	button_label.text = game_label

	var click_link = get_node("Button Game") as ClickLink
	click_link.url = button_link

	var scene_change = get_node("CollisionFrame") as ClickSceneChange
	scene_change.goto_scene = world_scene

	var display = get_node("Foam Card") as DisplayText
	display.page_text = credits
