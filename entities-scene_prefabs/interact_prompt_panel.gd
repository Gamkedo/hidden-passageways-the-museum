class_name InteractPromptPanel
extends PanelContainer

@export var interact_prompt_label: Label
@export var interaction_component: InteractionComponent
@export var cursor_texture: TextureRect

func handle_interactable_changed(interactable: InteractableObject) -> void:
	if interactable == null:
		hide_prompt()
	else:
		show_prompt_for(interactable)

func show_prompt_for(interactable: InteractableObject):
	interact_prompt_label.text = interactable.get_interaction_text()
	cursor_texture.texture = interactable.get_interaction_cursor()
	show()

func hide_prompt() -> void:
	interact_prompt_label.text = ""
	cursor_texture.texture = null
	hide()


func _ready() -> void:
	interaction_component.target_interactable_changed.connect(handle_interactable_changed)
	hide_prompt()
