class_name InteractionComponent
extends Node

signal target_interactable_changed(interactable: InteractableArea)

@export var character_controller: CharacterController
@export var detectors: Array[InteractionDetector]

var current_interactable: InteractableArea
# Use a queue in case multiple interactables overlap
var interactable_queue: Array[InteractableArea]


func begin_interaction_with(interactable: InteractableArea) -> void:
	interactable.progress_interaction()

func stop_interaction_with(interactable: InteractableArea) -> void:
	interactable.pause_interaction()

func current_interactable_enabled_updated(is_enabled: bool) -> void:
	if not is_enabled:
		remove_interactable_from_queue(current_interactable)

func add_interactable_to_queue(interactable: InteractableArea) -> void:
	if not interactable_queue.has(interactable):
		interactable_queue.push_back(interactable)
		reevaluate_current_interactable()

func remove_interactable_from_queue(interactable: InteractableArea) -> void:
	if interactable_queue.has(interactable):
		interactable_queue.erase(interactable)
		reevaluate_current_interactable()

#region CharacterController
func _on_player_interact_started() -> void:
	if current_interactable != null:
		begin_interaction_with(current_interactable)

func _on_player_interact_stopped() -> void:
	if current_interactable != null:
		stop_interaction_with(current_interactable)
#endregion CharacterController

#region InteractionDetector
func _on_detecting_interactable(interactable: InteractableArea) -> void:
	print("Detecting a new interactable!", interactable.name)
	add_interactable_to_queue(interactable)

func _on_stopped_detecting_interactable(interactable: InteractableArea) -> void:
	print("Lost interactable!", interactable.name)
	remove_interactable_from_queue(interactable)

func _connect_interactable_signals(interactable: InteractableArea) -> void:
	if is_instance_valid(interactable):
		if not interactable.enabled_updated.is_connected(current_interactable_enabled_updated):
			interactable.enabled_updated.connect(current_interactable_enabled_updated)

func _disconnect_interactable_signals(interactable: InteractableArea) -> void:
	if is_instance_valid(interactable):
		if interactable.enabled_updated.is_connected(current_interactable_enabled_updated):
			interactable.enabled_updated.disconnect(current_interactable_enabled_updated)
#endregion InteractionDetector

## Set current interactable to the "most important" one from the queue
func reevaluate_current_interactable() -> void:
	var last_interactable = current_interactable
	if interactable_queue.is_empty():
		current_interactable = null
	else:
		# TODO: For now just get the most recent one added.
		#       Could add logic to sort the list later by a priority (eg. collision_priority)
		var next_interactable: InteractableArea = interactable_queue.back()
		if next_interactable.enabled:
			current_interactable = next_interactable
	
	# 'null' for no more interactables available
	if last_interactable != current_interactable:
		_disconnect_interactable_signals(last_interactable)
		_connect_interactable_signals(current_interactable)
		target_interactable_changed.emit(current_interactable)


func _ready() -> void:
	if detectors.size() == 0:
		printerr("Interaction Component has no detectors! Will be unable to detect interactable objects!")
		return
	if not is_instance_valid(character_controller):
		printerr("Interaction Component has no controller! Will be unable to interact with objects!")
		return
		
	for detector in detectors:
		detector.detecting_interactable.connect(_on_detecting_interactable)
		detector.stopped_detecting_interactable.connect(_on_stopped_detecting_interactable)
	
	character_controller.interact_started.connect(_on_player_interact_started)
	character_controller.interact_stopped.connect(_on_player_interact_stopped)
