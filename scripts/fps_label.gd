extends Label

func _process(_delta: float) -> void:
	# measure how much texture ram we are using on the graphics card
	var vram_used_mb = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024 * 1024)
	text = "%d" % Engine.get_frames_per_second() + "FPS" + " - VRAM used: %d" % vram_used_mb + "MB"
