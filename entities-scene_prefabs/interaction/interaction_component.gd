class_name InteractionComponent
extends Node

signal target_interactable_changed(interactable: InteractableObject)

@export var character_controller: CharacterController
@export var detector: InteractionDetector

var current_interactable: InteractableObject
# Use a queue in case multiple interactables overlap
var interactable_queue: Array[InteractableObject]


func begin_interaction_with(interactable: InteractableObject) -> void:
	interactable.progress_interaction()

func stop_interaction_with(interactable: InteractableObject) -> void:
	interactable.pause_interaction()

#region CharacterController
func _on_player_interact_started() -> void:
	if current_interactable != null:
		begin_interaction_with(current_interactable)

func _on_player_interact_stopped() -> void:
	if current_interactable != null:
		stop_interaction_with(current_interactable)
#endregion CharacterController

#region InteractionDetector
func _on_detecting_interactable(interactable: InteractableObject) -> void:
	print("Deteting a new interactable!", interactable.name)
	if not interactable_queue.has(interactable):
		interactable_queue.push_back(interactable)
		reevaluate_current_interactable()

func _on_stopped_detecting_interactable(interactable: InteractableObject) -> void:
	print("Lost interactable!", interactable.name)
	if interactable_queue.has(interactable):
		interactable_queue.erase(interactable)
		reevaluate_current_interactable()
#endregion InteractionDetector

## Get the most important interactable from the queue
func reevaluate_current_interactable() -> void:
	if interactable_queue.is_empty():
		current_interactable = null
	else:
		# TODO: For now just get the most recent one added.
		#       Could add logic to sort the list later by a priority
		var next_interactable: InteractableObject = interactable_queue.back()
		current_interactable = next_interactable
	
	# 'null' for no more interactables available
	target_interactable_changed.emit(current_interactable)


func _ready() -> void:
	if not is_instance_valid(detector):
		printerr("Interaction Component has no detector! Will be unable to detect interactable objects!")
		return
	if not is_instance_valid(character_controller):
		printerr("Interaction Component has no controller! Will be unable to interact with objects!")
		return
	
	detector.detecting_interactable.connect(_on_detecting_interactable)
	detector.stopped_detecting_interactable.connect(_on_stopped_detecting_interactable)
	
	character_controller.interact_started.connect(_on_player_interact_started)
	character_controller.interact_stopped.connect(_on_player_interact_stopped)
