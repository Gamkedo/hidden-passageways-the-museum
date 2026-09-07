class_name InteractionDetector
extends Area3D

signal detecting_interactable(interactable: InteractableArea)
signal stopped_detecting_interactable(interactable: InteractableArea)

func detecting_object(object: Node3D) -> void:
	if object is InteractableArea:
		detecting_interactable.emit(object)

func stopped_detecting_object(object: Node3D) -> void:
	if object is InteractableArea:
		stopped_detecting_interactable.emit(object)

func _ready() -> void:
	body_entered.connect(detecting_object)
	area_entered.connect(detecting_object)
	
	body_exited.connect(stopped_detecting_object)
	area_exited.connect(stopped_detecting_object)
