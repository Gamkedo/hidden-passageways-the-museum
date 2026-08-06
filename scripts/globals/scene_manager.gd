extends Node

## Has aliases for [method SceneTree.change_scene_to_file] and [method SceneTree.change_scene_to_packed]

@export var show_scene_label: bool = true:
	set(v):
		show_scene_label = v
		if scene_label: scene_label.visible = v
	get:
		if not OS.is_debug_build():
			## disable on release builds
			return false
		return show_scene_label

@onready var scene_label: RichTextLabel = %DebugSceneLabel

func _ready() -> void:
	_initialize_scene_label()

## [method SceneTree.change_scene_to_file]
func change_scene_to_file(filepath: String) -> void:
	var scene: PackedScene = load(filepath)
	change_scene_to_packed(scene)

## [method SceneTree.change_scene_to_packed]
func change_scene_to_packed(packed_scene: PackedScene) -> void:
	var err: Error = get_tree().change_scene_to_packed(packed_scene)
	assert(err == Error.OK, "Failed to change scene to packed scene (%s)" % packed_scene)
	
	if scene_label:
		scene_label.text = format_scene_name(packed_scene)


func _initialize_scene_label() -> void:
	var path = ResourceUID.get_id_path(
		ResourceUID.text_to_id(
			ProjectSettings.get_setting("application/run/main_scene")
			)
		)
	scene_label.text = format_resource_path(path)
	scene_label.visible = show_scene_label

static func format_scene_name(packed_scene: PackedScene) -> String:
	return format_resource_path(packed_scene.resource_path)

static func format_resource_path(path: String) -> String:
	return (
		path.get_base_dir()
		+ "/  [b]"
		+ path.get_file().trim_suffix(".tscn")
		+ "[/b]  .tscn"
	)
