extends MeshInstance3D

@export var rotation_speed: float = 0.01

func _process(delta: float) -> void:
	# Spins the mesh slowly around the Y axis
	rotation.y += rotation_speed * delta
