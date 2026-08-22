@abstract
class_name IconActionMap
extends Resource

const INPUT_BINDS: InputBinds = preload("uid://dnfis17edcjtb")


## This is what drives the mapping in-code to determine which icon to display
func get_icon_for_event(event: InputEvent) -> Texture2D:
	var all_mappings := _get_all_icon_mappings()
	var mapped_events: Array[InputEvent] = all_mappings.keys()
	var matching_mapping_index: int = mapped_events.find_custom(_has_matching_event.bind(event))
	
	var event_icon: Texture2D = null
	if matching_mapping_index != -1:
		var matching_event: InputEvent = mapped_events[matching_mapping_index]
		event_icon = all_mappings[matching_event]
	return event_icon

func _has_matching_event(mapping: InputEvent, event: InputEvent) -> bool:
	if event.is_match(mapping):
		return true
	return false

# Get all mappings as a single dictionary
@abstract
func _get_all_icon_mappings() -> Dictionary[InputEvent, Texture2D]
