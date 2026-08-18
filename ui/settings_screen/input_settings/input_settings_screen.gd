class_name InputSettingsScreen
extends PanelContainer

signal input_settings_ui_changed

var INPUT_SETTINGS: InputSettings = preload("uid://b0g4cokh6wa10")

@onready var m_horizontal_slider: HSlider = %MHorizontalSlider
@onready var m_vertical_slider: HSlider = %MVerticalSlider
@onready var m_invert_y_look_checkbox: CheckBox = %MInvertYLookCheckbox
@onready var c_horizontal_slider: HSlider = %CHorizontalSlider
@onready var c_vertical_slider: HSlider = %CVerticalSlider
@onready var c_invert_y_look_check_box: CheckBox = %CInvertYLookCheckBox
@onready var toggle_sprint_checkbox: CheckBox = %ToggleSprintCheckbox


func load_settings_to_ui() -> void:
	print("[InputSettingsScreen] Loading settings to ui")
	m_horizontal_slider.value = INPUT_SETTINGS.mouse_horizontal_sensitivity
	m_vertical_slider.value = INPUT_SETTINGS.mouse_vertical_sensitivity
	m_invert_y_look_checkbox.button_pressed = INPUT_SETTINGS.mouse_invert_y_look
	c_horizontal_slider.value = INPUT_SETTINGS.controller_horizontal_sensitivity
	c_vertical_slider.value = INPUT_SETTINGS.controller_vertical_sensitivity
	c_invert_y_look_check_box.button_pressed = INPUT_SETTINGS.controller_invert_y_look
	toggle_sprint_checkbox.button_pressed = INPUT_SETTINGS.toggle_sprint

func sync_m_horizontal_sens_to_settings(value: float) -> void:
	INPUT_SETTINGS.mouse_horizontal_sensitivity = value
	input_settings_ui_changed.emit()

func sync_m_vertical_sens_to_settings(value: float) -> void:
	INPUT_SETTINGS.mouse_vertical_sensitivity = value
	input_settings_ui_changed.emit()

func sync_m_invert_y_to_settings(toggled: bool) -> void:
	INPUT_SETTINGS.mouse_invert_y_look = toggled
	input_settings_ui_changed.emit()

func sync_c_horizontal_sens_to_settings(value: float) -> void:
	INPUT_SETTINGS.controller_horizontal_sensitivity = value
	input_settings_ui_changed.emit()

func sync_c_vertical_sens_to_settings(value: float) -> void:
	INPUT_SETTINGS.controller_vertical_sensitivity = value
	input_settings_ui_changed.emit()

func sync_c_invert_y_to_settings(toggled: bool) -> void:
	INPUT_SETTINGS.controller_invert_y_look = toggled
	input_settings_ui_changed.emit()

func sync_toggle_sprint_to_settings(toggled: bool) -> void:
	INPUT_SETTINGS.toggle_sprint = toggled
	input_settings_ui_changed.emit()


func _connect_signals() -> void:
	m_horizontal_slider.value_changed.connect(sync_m_horizontal_sens_to_settings)
	m_vertical_slider.value_changed.connect(sync_m_vertical_sens_to_settings)
	m_invert_y_look_checkbox.toggled.connect(sync_m_invert_y_to_settings)
	c_horizontal_slider.value_changed.connect(sync_c_horizontal_sens_to_settings)
	c_vertical_slider.value_changed.connect(sync_c_vertical_sens_to_settings)
	c_invert_y_look_check_box.toggled.connect(sync_c_invert_y_to_settings)
	toggle_sprint_checkbox.toggled.connect(sync_toggle_sprint_to_settings)

func _on_input_settings_updated() -> void:
	load_settings_to_ui()

func _ready() -> void:
	load_settings_to_ui()
	
	# Intentionally connecting signal after loading setting state
	INPUT_SETTINGS.input_settings_updated.connect(_on_input_settings_updated)
	_connect_signals()
