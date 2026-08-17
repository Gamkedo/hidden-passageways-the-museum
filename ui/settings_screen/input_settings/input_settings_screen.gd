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


func load_settings_to_ui() -> void:
	m_horizontal_slider.value = INPUT_SETTINGS.mouse_horizontal_sensitivity
	m_vertical_slider.value = INPUT_SETTINGS.mouse_vertical_sensitivity
	m_invert_y_look_checkbox.value = INPUT_SETTINGS.mouse_invert_y_look
	c_horizontal_slider.value = INPUT_SETTINGS.controller_horizontal_sensitivity
	c_vertical_slider.value = INPUT_SETTINGS.controller_vertical_sensitivity
	c_invert_y_look_check_box.value = INPUT_SETTINGS.controller_invert_y_look

func sync_m_horizontal_sens_to_settings() -> void:
	INPUT_SETTINGS.mouse_horizontal_sensitivity = m_horizontal_slider.value
	input_settings_ui_changed.emit()

func sync_m_vertical_sens_to_settings() -> void:
	INPUT_SETTINGS.mouse_vertical_sensitivity = m_vertical_slider.value
	input_settings_ui_changed.emit()

func sync_m_invert_y_to_settings() -> void:
	INPUT_SETTINGS.mouse_invert_y_look = m_invert_y_look_checkbox.value
	input_settings_ui_changed.emit()

func sync_c_horizontal_sens_to_settings() -> void:
	INPUT_SETTINGS.controller_horizontal_sensitivity = c_horizontal_slider.value
	input_settings_ui_changed.emit()

func sync_c_vertical_sens_to_settings() -> void:
	INPUT_SETTINGS.controller_vertical_sensitivity = c_vertical_slider.value
	input_settings_ui_changed.emit()

func sync_c_invert_y_to_settings() -> void:
	INPUT_SETTINGS.controller_invert_y_look = c_invert_y_look_check_box.value
	input_settings_ui_changed.emit()


func _connect_signals() -> void:
	m_horizontal_slider.value_changed.connect(sync_m_horizontal_sens_to_settings)
	m_vertical_slider.value_changed.connect(sync_m_vertical_sens_to_settings)
	m_invert_y_look_checkbox.toggled.connect(sync_m_invert_y_to_settings)
	c_horizontal_slider.value_changed.connect(sync_c_horizontal_sens_to_settings)
	c_vertical_slider.value_changed.connect(sync_c_vertical_sens_to_settings)
	c_invert_y_look_check_box.toggled.connect(sync_c_invert_y_to_settings)


func _ready() -> void:
	_connect_signals()
