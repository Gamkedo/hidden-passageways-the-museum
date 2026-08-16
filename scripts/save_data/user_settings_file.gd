class_name UserSettingsFile
extends ConfigFile

const SAVE_FILE_PATH_ROOT := "user://save_data/"
const USER_SETTINGS_PATH := "user_settings.save"

const CONTROLS_SECTION := "Controls"
const INPUT_SETTINGS_SECTION := "InputSettings"

const INPUT_SETTINGS: InputSettings = preload("uid://b0g4cokh6wa10")


## Load settings from a saved file and apply them to the running project
func load_and_apply_settings() -> void:
	load_settings()
	
	# Apply custom user settings from saved data
	var input_settings := build_input_settings()
	apply_input_settings(input_settings)
	
	# Apply controls to InputMap from saved data
	var control_settings := build_controls()
	apply_control_settings(control_settings)

## Save the settings currently active in the project to the save file
func save_current_settings() -> void:
	hydrate_input_settings()
	hydrate_controls_from_input_map()
	save_settings()


#region Controls
## Apply controls from this ConfigFile into the InputMap
func apply_control_settings(controls: Dictionary) -> void:
	ControlSettings.save_to_input_map(controls)

## Build a dictionary of control mappings from this ConfigFile
func build_controls() -> Dictionary:
	# Will return an empty dictionary if the section isn't found
	var controls_dictionary := {}
	
	if has_section(CONTROLS_SECTION):
		var control_section_keys := get_section_keys(CONTROLS_SECTION)
		for control_key in control_section_keys:
			controls_dictionary[control_key] = get_value(CONTROLS_SECTION, control_key)
	
	return controls_dictionary

## Hydrate the control mappings from the InputMap into this ConfigFile 
func hydrate_controls_from_input_map() -> void:
	var current_controls := ControlSettings.get_controls_from_input_map()
	for action_name in current_controls:
		set_value(CONTROLS_SECTION, action_name, current_controls[action_name])
#endregion Controls

#region Input Settings
## Apply the input settings to the project resource that drives 'InputSettings'
func apply_input_settings(input_settings: Dictionary) -> void:
	INPUT_SETTINGS.load_from_serialized(input_settings)

## Build a dictionary if input settings from this ConfigFile
func build_input_settings() -> Dictionary:
	# Will return an empty dictionary if the section isn't found
	var input_settings := {}
	
	if has_section(INPUT_SETTINGS_SECTION):
		var input_settings_section_keys := get_section_keys(INPUT_SETTINGS_SECTION)
		for input_settings_key in input_settings_section_keys:
			input_settings[input_settings_key] = get_value(INPUT_SETTINGS_SECTION, input_settings_key)
	
	return input_settings

## Hydrate input settings from the InputSettings resource into this Config File
func hydrate_input_settings() -> void:
	var current_input_settings := INPUT_SETTINGS.serialize()
	for setting_name in current_input_settings:
		set_value(INPUT_SETTINGS_SECTION, setting_name, current_input_settings[setting_name])
#endregion Input Settings

#region Save & Load
## Hydrate this ConfigFile with data from the save file
func load_settings() -> void:
	var file_path := get_settings_file_path()
	# "self" is required here otherwise the Global "load" takes precedence
	var load_status := self.load(file_path)
	print("[UserSettings] Load status: ", load_status)

## Save a ".ini"-style file to the file system with settings data from this ConfigFile
func save_settings() -> void:
	var file_path := get_settings_file_path()
	var save_status := save(file_path)
	print("[UserSettings] Save status: ", save_status)

func get_settings_file_path() -> String:
	return SAVE_FILE_PATH_ROOT + USER_SETTINGS_PATH
#endregion Save & Load
