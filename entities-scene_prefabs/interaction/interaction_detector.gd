class_name InteractionDetector
extends Area3D

signal detecting_interactable(interactable: InteractableObject)
signal stopped_detecting_interactable(interactable: InteractableObject)

func detecting_object(object: Node3D) -> void:
	if object is InteractableObject:
		detecting_interactable.emit(object)

func stopped_detecting_object(object: Node3D) -> void:
	if object is InteractableObject:
		stopped_detecting_interactable.emit(object)

func _ready() -> void:
	body_entered.connect(detecting_object)
	area_entered.connect(detecting_object)
	
	body_exited.connect(stopped_detecting_object)
	area_exited.connect(stopped_detecting_object)
