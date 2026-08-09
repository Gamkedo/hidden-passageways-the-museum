extends TabContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tab_count() > 1:
		var t: Tween = create_tween()
		t.tween_property(self, "current_tab", get_tab_count()-1, 5.0).from(0)
		t.set_loops()
