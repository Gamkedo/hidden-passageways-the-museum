extends StaticBody3D

enum Actions {
	APPLY_CLAY_MATERIAL = 0,
	
}

@export var action_when_pressed: Actions
@export var nodes: Array[Node3D]

var _toggled_on: bool = false

func manipulate_mesh() -> void:
	toggle()
	match action_when_pressed:
		Actions.APPLY_CLAY_MATERIAL:
			for n in nodes:
				if n is GeometryInstance3D:
					if _toggled_on:
						MeshUtils.clay_mat(n)
					else:
						MeshUtils.clear_mat_override(n)
		_:
			push_warning("Unconfigured behavior for action_when_pressed: %s" % action_when_pressed)

func toggle() -> void:
	_toggled_on = not _toggled_on
