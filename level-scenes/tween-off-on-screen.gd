extends VisibleOnScreenNotifier3D

## Sentience
## WARNING

const DEBUG: bool = false

enum Styles {
	MOVE_TOWARDS = 0,
	DISAPPEARING = 1, ## not implemented (yet?)
}

@export var style: Styles
@export var use_model_front: bool = true
@export var initial_wait_time: float = 15.0

@export var use_raycast_vision: bool = false ## Not working appropriately
@export var distance_vision: float = 55.0

var node: Node3D
var viewer: Camera3D:
	get: return get_viewport().get_camera_3d()
var origin: Vector3
var origin_rotation: Vector3

var last_seen: float = -1.0

var t: Tween
var _initial: Tween

func p(arg) -> void:
	if DEBUG:
		print("%s haunting: " % self.get_instance_id(), arg)

func _ready() -> void:
	if randf() > 0.5:
		queue_free()
		return
	
	origin = self.global_position
	origin_rotation = self.global_rotation
	node = get_parent()
	
	wait()
	screen_exited.connect(_on_screen_exited)
	screen_entered.connect(_on_screen_entered)

func _on_screen_exited() -> void:
	haunt()

func _on_screen_entered() -> void:
	var is_seen: bool = _raycast_result() if use_raycast_vision else true
	var distance_to: float = node.global_position.distance_to(viewer.global_position)
	if is_seen and distance_to < distance_vision:
		last_seen = Time.get_ticks_msec()
		p("last seen just now.")
		retreat()

func _time_since_last_seen() -> float: ## seconds
	return (Time.get_ticks_msec() - last_seen) / 1000.0

func haunt() -> void:
	if (not origin) or (not node) or (not viewer):
		p("missing")
		return
	
	if _initial or is_on_screen():
		return
		
	match style:
		Styles.MOVE_TOWARDS:
			_haunt_move_towards()
		Styles.DISAPPEARING:
			_haunt_disappearing()

func _haunt_move_towards() -> void:
	p("haunting")
	if t: t.kill()
	
	var distance_to: float = node.global_position.distance_to(viewer.global_position)
	p("distance is %s" % distance_to)
	if distance_to < 4.0:
		p("danger close")
		return
	
	t = create_tween()
	t.tween_callback(face_viewer)
	t.tween_property(
		node,
		"global_position",
		node.global_position.move_toward(
			viewer.global_position - viewer.position, randf_range(0.1, 1.5)),
		randf_range(0.5, 2.0))
	t.tween_interval(randf_range(0.2, 1.2))
	t.tween_callback(haunt)
	
func retreat() -> void:
	if (not origin) or (not node):
		return
	
	if _initial:
		return
	
	p("retreating")
	if t: t.kill()
	t = create_tween()
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_SINE)
	t.tween_interval(randf_range(0.09, 0.3))
	t.tween_property(node, "global_position", origin, 0.7)
	t.parallel()
	t.tween_property(node, "global_rotation", origin_rotation, 0.3)
	wait()

func wait() -> void:
	if initial_wait_time > 0.0:
		p("waiting")
		_initial = create_tween()
		_initial.tween_interval(initial_wait_time + randf_range(0., initial_wait_time))
		_initial.tween_callback(haunt)
	else:
		p("no wait time")

func face_viewer() -> void:
	node.look_at(viewer.global_position, Vector3.UP, use_model_front)

func _raycast_result() -> bool:
	var space_state = viewer.get_world_3d().direct_space_state
	var from = global_position
	var to = viewer.global_position

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.hit_from_inside = false
	query.collision_mask = 3
	var result = space_state.intersect_ray(query)

	if result:
		#p(result)
		var hit = result.collider
		if hit is CharacterBody3D:
			## it's (probably) the player
			return true
	return false

func _haunt_disappearing() -> void:
	if t:
		# cycle is working
		return
	
	if last_seen < 0.0:
		# never seen
		return
	
	if node.visible:
		t = create_tween()
		t.tween_interval(randf_range(5.0, 15.0))
		t.tween_callback(node.hide)
		t.tween_property(node, "global_position", Vector3.INF, 0.0)
		t.tween_interval(randf_range(60.0, 300.0))
	
	else:
		var position_behind_player: Vector3 = viewer.global_position + (-viewer.global_basis.z * 1.0)
		
		t = create_tween()
		t.tween_interval(randf_range(5.0, 15.0))
		t.tween_property(node, "global_position", position_behind_player, 0.0)
		t.tween_await(get_tree().process_frame)
		t.tween_callback(node.show)
