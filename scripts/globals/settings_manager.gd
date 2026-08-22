#class_name SettingsManager
extends Node

# Settings are a little weird due to how they are stored.
# - InputSettings are project-specific settings owned by the project itself
#   - Examples: Toggle Sprint, Look Sensitivity
# - InputBinds are controlled by Godot via InputMap and processed in the project by name
#   - Examples: Jump, Move (Up/Down/Left/Right)
# ~~~~~
# As a result, we handle each "type" of setting a little differently. When moving the data
#  between the save file and the running project, we need a passthrough to interpret the
#  settings data and load it into the project so that it can take effect.
# - InputSettings:
#   - InputSettings Save File <-> In-project InputSettings Resource
# - InputBinds:
#   - InputBinds Saved Resource <-> In-project InputBinds Resource <-> InputMap
# ~~~~~
# InputSettings are easier since we just need to update the Resource
# as that directly drives the code. Changes to that Resource immediately
# take effect in-game.
#
# InputBinds are only a passthrough object to make setting the InputEvents easier
# via the editor. InputMap is the real "source of truth" for input bindings. To
# set an input bind and have it take effect, it must be done through the InputMap.
# However it can't be directly accessed or manipulated very simply, so InputBinds
# (the resource) is our "mirror" to update actual bindings and save those bindings
# to the respective file.

## Enable to autosave settings changes to file with a debounce timer
@export var autosave: bool = false

const INPUT_BINDS: InputBinds = preload("uid://dnfis17edcjtb")
const INPUT_SETTINGS: InputSettings = preload("uid://b0g4cokh6wa10")

const SAVE_FILE_PATH_ROOT := "user://save_data/"
const INPUT_SETTINGS_PATH := "input_settings.save"
const INPUT_BINDS_SAVE_PATH := "controls.save"

@onready var save_debounce_timer: Timer = %SaveDebounceTimer


func save_input_to_settings(action_name: StringName, input_event: InputEvent) -> void:
	if input_event != null:
		INPUT_BINDS.remap_event_in_input_map(action_name, input_event)

#region Input Settings
func load_and_apply_settings_from_file() -> void:
	print("[SettingsManager] Loading settings state from file and applying")
	INPUT_SETTINGS.load_from_file(SAVE_FILE_PATH_ROOT, INPUT_SETTINGS_PATH)

func save_current_settings_to_file() -> void:
	print("[SettingsManager] Saving current settings state to file")
	INPUT_SETTINGS.save_to_file(SAVE_FILE_PATH_ROOT, INPUT_SETTINGS_PATH)

func _on_input_settings_changed() -> void:
	handle_settings_changed()

func get_settings_file_path() -> String:
	return SAVE_FILE_PATH_ROOT + INPUT_SETTINGS_PATH
#region Input Settings

#region Controls
func load_controls_from_file() -> void:
	print("[SettingsManager] Loading control mappings from file")
	INPUT_BINDS.load_from_file(SAVE_FILE_PATH_ROOT, INPUT_BINDS_SAVE_PATH)

func save_controls_to_file() -> void:
	print("[SettingsManager] Saving control mappings from file")
	INPUT_BINDS.save_to_file(SAVE_FILE_PATH_ROOT, INPUT_BINDS_SAVE_PATH)

func reset_binds_to_default() -> void:
	INPUT_BINDS.reset_binds(SAVE_FILE_PATH_ROOT, INPUT_BINDS_SAVE_PATH)

func _on_input_map_changed() -> void:
	handle_settings_changed()

func get_input_binds_file_name() -> String:
	return SAVE_FILE_PATH_ROOT + INPUT_BINDS_SAVE_PATH
#endregion Controls


## Respond to settings changes.
## If using autosave, use a debounce timer to trigger the save operation
func handle_settings_changed() -> void:
	# ProjectSettings technically "update" on first load frame, so ignore that one
	var process_frames_passed := Engine.get_process_frames()
	if autosave and process_frames_passed > 0:
		save_debounce_timer.start(1.0)

func _on_save_timer_timeout() -> void:
	save_current_settings_to_file()
	save_controls_to_file()

func _ready() -> void:
	# Intentionally calling this before wiring signals to prevent triggering a file save
	load_and_apply_settings_from_file()
	load_controls_from_file()
	
	# Capture changes to controls (InputMap) or custom input settings
	INPUT_SETTINGS.input_settings_updated.connect(_on_input_settings_changed)
	INPUT_BINDS.input_map_updated.connect(_on_input_map_changed)
	
	save_debounce_timer.timeout.connect(_on_save_timer_timeout)
