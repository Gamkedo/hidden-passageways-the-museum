#class_name SettingsManager
extends Node

## Enable to autosave settings changes to file with a debounce timer
@export var autosave: bool = false

const INPUT_SETTINGS: InputSettings = preload("uid://b0g4cokh6wa10")

@onready var save_debounce_timer: Timer = %SaveDebounceTimer


func load_and_apply_settings_from_file() -> void:
	var user_settings := UserSettingsFile.new()
	user_settings.load_and_apply_settings()

func save_current_settings_to_file() -> void:
	var user_settings := UserSettingsFile.new()
	user_settings.save_current_settings()


func _on_settings_changed() -> void:
	if autosave:
		save_debounce_timer.start()

func _on_save_timer_timeout() -> void:
	save_current_settings_to_file()

func _ready() -> void:
	# Intentionally calling this before wiring signals to prevent triggering a file save
	load_and_apply_settings_from_file()
	
	# Capture changes to controls (InputMap) or custom input settings
	ProjectSettings.settings_changed.connect(_on_settings_changed)
	INPUT_SETTINGS.changed.connect(_on_settings_changed)
	
	save_debounce_timer.timeout.connect(_on_save_timer_timeout)
