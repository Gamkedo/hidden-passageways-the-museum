class_name DisplayText
extends StaticBody3D

@export_multiline var page_text: String

@onready var form_card_interactable: InteractableArea = %FormCardInteractable


func text_to_display() -> String:
	return page_text

func display_text_for_player() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player")
	if is_instance_valid(player):
		var display_text := text_to_display()
		player.page_text_panel.show_text(display_text)

func _on_interaction_complete() -> void:
	display_text_for_player()

func _ready() -> void:
	form_card_interactable.interaction_complete.connect(_on_interaction_complete)
