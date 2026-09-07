class_name InteractPromptPanel
extends PanelContainer

@export var interact_prompt_label: Label
@export var interaction_component: InteractionComponent
@export var player_cursor: PlayerCursor


func handle_interactable_changed(interactable: InteractableArea) -> void:
	if interactable == null:
		hide_prompt()
	else:
		show_prompt_for(interactable)

func show_prompt_for(interactable: InteractableArea):
	interact_prompt_label.text = interactable.get_interaction_text()
	show()
	var cursor_texture := interactable.get_interaction_cursor()
	player_cursor.display_cursor_texture(cursor_texture)

func hide_prompt() -> void:
	interact_prompt_label.text = ""
	hide()
	if is_instance_valid(player_cursor):
		player_cursor.display_default_cursor()


func _process(_delta: float) -> void:
	var current_interactable := interaction_component.current_interactable
	if is_instance_valid(current_interactable):
		var current_interact_time := current_interactable.current_interaction_time
		var max_interact_time := current_interactable.interaction_time
		player_cursor.set_cursor_progress(current_interact_time, max_interact_time)

func _ready() -> void:
	interaction_component.target_interactable_changed.connect(handle_interactable_changed)
	hide_prompt()
