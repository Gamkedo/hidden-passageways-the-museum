@tool
extends Sprite3D

@export var frame_time: float = 1.0/12.0:
	set(v):
		frame_time = v
		check_run()
		
@export var run_in_editor: bool = true:
	set(v):
		run_in_editor = v
		check_run()

var _t: Tween

func _ready() -> void: check_run()

func check_run() -> void:
	if Engine.is_editor_hint():
		if not run_in_editor:
			if _t: _t.kill()
			return
	animate()
	
func animate() -> void:
	if _t:
		_t.kill()
	_t = create_tween()
	_t.set_trans(Tween.TRANS_LINEAR)
	_t.tween_property(self, "frame", hframes - 1, frame_time * (hframes - 1)).from(0)
	_t.tween_interval(1.7)
	_t.set_loops()
