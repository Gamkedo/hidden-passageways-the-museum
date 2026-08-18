class_name SettingsScreen
extends PanelContainer

## Set to 'false' to hide the heading label (eg. for when inside a TabContainer)
@export var show_heading: bool = true

@onready var input_settings_screen: InputSettingsScreen = %InputSettingsScreen
@onready var controls_screen: InputBindsScreen = %ControlsScreen
