class_name DynamicBillboard
extends StaticBody3D
@onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer


func _ready() -> void:
	# Remove the layer with the subviewport container from the main viewport
	# (Apparently this can only be done via code)
	# FIXME: Push this to a global game handler at the top level
	get_viewport().canvas_cull_mask -= sub_viewport_container.visibility_layer
