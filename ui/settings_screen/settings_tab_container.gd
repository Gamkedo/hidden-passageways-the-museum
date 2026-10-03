class_name SettingsTabContainer
extends PanelContainer

var all_child_inputs: Array[Control]

func focus_first_input() -> void:
	var input_controls := get_child_inputs()
	var first_input := input_controls[0]
	first_input.grab_focus()

## Get the list of child inputs that actually accept input (eg. skip Labels)
func get_child_inputs() -> Array[Control]:
	return all_child_inputs

func _register_child_inputs() -> void:
	var all_children: Array[Control]
	all_children.assign(find_children("*", "", true))
	var all_input_controls := all_children.filter(func(control: Control):
		var control_accepts_input := _control_accepts_input(control)
		return control_accepts_input
	)
	all_child_inputs = all_input_controls

func _control_accepts_input(control_node: Control) -> bool:
	var accepts_input := \
		control_node is BaseButton or \
		control_node is Slider or \
		control_node is SpinBox or \
		control_node is LineEdit or \
		control_node is TextEdit
	return accepts_input

func _ready() -> void:
	_register_child_inputs()
