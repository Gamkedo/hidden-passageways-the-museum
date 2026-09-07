@tool
extends StaticBody3D

@export_category("Button Stand")
@export_multiline var game_label: String = "":
	set = set_game_label
@export var button_link: String = ""
@export var button_interact_text: String

@export_category("Exhibit Frame")
@export_file("*.tscn") var world_scene: String = ""
@export var frame_interact_text: String

@export_category("Credits")
@export_multiline var credits: String = ""

@export_category("Textures")
@export var painting_texture: Texture2D:
	set = set_painting_texture
@export var button_texture: Texture2D:
	set = set_button_texture

@onready var scene_changer: ClickSceneChange = %ClickSceneChange
@onready var button_click_link: ClickLink = %ButtonClickLink
@onready var button_label: Label3D = %GameLabel
@onready var play_stand_interactable: InteractableArea = %PlayStandInteractable
@onready var frame_interactable: InteractableArea = %FrameInteractable

var was_painting_texture: Texture2D
var was_button_texture: Texture2D


func set_painting_texture(new_painting: Texture2D) -> void:
	if painting_texture != new_painting:
		painting_texture = new_painting
		show_images_from_inspector()


func set_button_texture(new_button: Texture2D) -> void:
	if button_texture != new_button:
		button_texture = new_button
		show_images_from_inspector()

func show_images_from_inspector():
	var painting_image := $"BasicCurvyFrame Test/Painting Image"
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = painting_texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	painting_image.material_override = material

	var button_image := $"Button Game/Button image"
	material = StandardMaterial3D.new()
	material.albedo_texture = button_texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	button_image.material_override = material

func _ready() -> void:
	show_images_from_inspector()

	button_label.text = game_label

	button_click_link.url = button_link
	
	var display = get_node("Foam Card") as DisplayText
	display.page_text = credits

	if not Engine.is_editor_hint():
		play_stand_interactable.interaction_complete.connect(open_link)
		if button_interact_text != "":
			play_stand_interactable.set_interaction_text(button_interact_text)
		
		scene_changer.goto_scene = world_scene
		frame_interactable.interaction_complete.connect(open_scene)
		if frame_interact_text != "":
			frame_interactable.set_interaction_text(frame_interact_text)

func set_game_label(new_label: String) -> void:
	game_label = new_label
	if is_instance_valid(button_label):
		button_label.text = game_label

func open_link() -> void:
	button_click_link.open_link()

func open_scene() -> void:
	scene_changer.open_scene()
