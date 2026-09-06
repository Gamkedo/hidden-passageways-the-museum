extends StaticBody3D

@export_multiline var game_label: String = ""
@export var button_link: String = ""
@export_file("*.tscn") var world_scene: String = ""
@export_multiline var credits: String = ""

@export var painting_texture_big: Texture2D
@export var button_texture: Texture2D

func _ready() -> void:
	var painting_image := $"BasicCurvyFrame Test/Painting Image"
	var material: StandardMaterial3D = painting_image.material_override.duplicate()
	material.albedo_texture = painting_texture_big
	painting_image.material_override = material

	var button_image := $"Button Game/Button image"
	material = button_image.material_override.duplicate()
	material.albedo_texture = button_texture
	button_image.material_override = material
	
	var button_label = get_node("Button Game/GameLabel") as Label3D
	button_label.text = game_label

	var click_link = get_node("Button Game") as ClickLink
	click_link.url = button_link

	var display = get_node("Foam Card") as DisplayText
	display.page_text = credits

func open_scene():
	if world_scene.is_empty():
		push_warning("Empty goto_scene property for open_scene. Configure in Inspector.")
		return
	
	print("Changing scene (did file change?) to:", world_scene)
	SceneManager.change_scene_to_file(world_scene)
