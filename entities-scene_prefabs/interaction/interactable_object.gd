@abstract
class_name InteractableObject
extends CollisionObject3D

signal interaction_started
signal interaction_stopped
signal interaction_complete

@export_category("Text Prompt")
@export_multiline() var interact_prompt: String
@export_enum(" ", "Hold to", "Press to") var interaction_prompt_prefix: String = ""

@export_category("Interaction Details")
## Time to complete the interaction. Set to 0 for instant interaction on button press
@export_range(0, 120) var interaction_time: float
## Texture to replace the cursor with when the object can be interacted with
@export var interaction_cursor: Texture2D = preload("uid://bqu3ku7v8yoeu")

var current_interaction_time: float = 0
var _progressing_interaction: bool = false

@abstract
func trigger_interaction() -> void

func progress_interaction() -> void:
	if interaction_time == 0:
		trigger_interaction()
	else:
		_progressing_interaction = true
		interaction_started.emit()

func pause_interaction() -> void:
	_progressing_interaction = false
	current_interaction_time = 0
	interaction_stopped.emit()

func _handle_interaction_progress(delta: float) -> void:
	if _progressing_interaction:
		current_interaction_time += delta
		if current_interaction_time >= interaction_time:
			interaction_complete.emit()

func get_current_interaction_progress() -> float:
	var current_progress := current_interaction_time / interaction_time
	return current_progress

func get_interaction_text() -> String:
	var prefix := interaction_prompt_prefix
	prefix = prefix.strip_edges() # Trim whitespace
	if prefix.length() > 0:
		prefix += " " # Add a single space if there is still prefix text
	
	var interaction_text = prefix + interact_prompt
	return interaction_text

func get_interaction_cursor() -> Texture2D:
	return interaction_cursor


func _process(delta: float) -> void:
	_handle_interaction_progress(delta)
