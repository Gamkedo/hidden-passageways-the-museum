class_name MeshUtils

const MAT_CLAY: StandardMaterial3D = preload("uid://cxick4fh6p4he")

static func clay_mat(geo: GeometryInstance3D) -> void:
	geo.material_override = MAT_CLAY
	
static func clear_mat_override(geo: GeometryInstance3D) -> void:
	geo.material_override = null
