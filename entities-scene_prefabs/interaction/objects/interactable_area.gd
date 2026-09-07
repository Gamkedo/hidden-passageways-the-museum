class_name InteractableArea
extends Area3D

signal interaction_started
signal interaction_stopped
signal interaction_complete
signal enabled_updated(is_enabled: bool)

@export_category("Text Prompt")
@export_multiline() var interact_prompt: String:
	set = set_interaction_text
@export_enum(" ", "Hold to", "Press to") var interaction_prompt_prefix: String = ""

@export_category("Interaction Details")
## Time to complete the interaction. Set to 0 for instant interaction on button press
@export_range(0, 120) var interaction_time: float
## Texture to replace the cursor with when the object can be interacted with
@export var interaction_cursor: Texture2D = preload("uid://bqu3ku7v8yoeu")
## Set to 'true' to disable the interactable entirely after interaction is complete
@export var disable_after_interaction: bool = false
@export var reset_progress_on_interact_stopped: bool = true

var enabled: bool = true:
	set = set_enabled
var current_interaction_time: float = 0
var _progressing_interaction: bool = false


func trigger_interaction() -> void:
	if enabled:
		interaction_complete.emit()
		if disable_after_interaction:
			enabled = false

## Begin progressing the interaction.
## Instantly activates the effect if the [interaction_time] is 0
## Override for custom logic around starting/restarting your interaction
func progress_interaction() -> void:
	if not enabled:
		return
	
	if interaction_time == 0:
		trigger_interaction()
	else:
		_progressing_interaction = true
		interaction_started.emit()

func pause_interaction() -> void:
	_progressing_interaction = false
	if reset_progress_on_interact_stopped:
		current_interaction_time = 0
	interaction_stopped.emit()

func set_enabled(is_enabled: bool) -> void:
	if enabled != is_enabled:
		enabled = is_enabled
		enabled_updated.emit(enabled)

func _handle_interaction_progress(delta: float) -> void:
	if enabled and _progressing_interaction:
		current_interaction_time += delta
		if current_interaction_time >= interaction_time:
			trigger_interaction()

func get_current_interaction_progress() -> float:
	var current_progress := current_interaction_time / interaction_time
	return current_progress

#region Visual Indicators
func get_interaction_text() -> String:
	var prefix := interaction_prompt_prefix
	prefix = prefix.strip_edges() # Trim whitespace
	if prefix.length() > 0:
		prefix += " " # Add a single space if there is still prefix text
	
	var interaction_text = prefix + interact_prompt
	return interaction_text

func set_interaction_text(new_text: String) -> void:
	interact_prompt = new_text

func get_interaction_cursor() -> Texture2D:
	return interaction_cursor
#endregion Visual Indicators


func _process(delta: float) -> void:
	_handle_interaction_progress(delta)
