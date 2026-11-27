extends Node3D
# old Unity camelCase, crudely adapted one-off script from a 2016 prototype shown at 1 meeting
var moveMult := 1.0
var rateMult := 1.0
var phaseShift := 0.0
var startPos: Vector3

func _ready() -> void:
	startPos = global_position

func _process(delta: float) -> void:
	var useTime = (Time.get_ticks_msec() / 1000.0 + phaseShift) * rateMult
	global_position = startPos + (Vector3.UP * cos(useTime * 0.5) * 0.2 + Vector3.RIGHT * cos(useTime * 0.15) * 0.02 + Vector3.FORWARD * cos(useTime * 0.07) * 0.01) * moveMult
