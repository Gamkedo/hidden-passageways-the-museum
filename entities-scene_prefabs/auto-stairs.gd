@tool
class_name AutoStairs extends CSGCombiner3D

const CLEAR_ALL_CHILDREN: bool = true
const PREVENT_RUNTIME_REGEN: bool = true ## disable if you want to experiment with this deliberately

enum RiserStyles {
	OPEN = 0,
	CLOSED = 1
}
enum StringerStyles {
	NONE = 0,
	CLOSED = 1,
	SAWTOOTH = 2,
	MONO = 3,
	CANTILEVER = 4,
}

## *Warning!* Destroys all children!
@export_tool_button("Generate") var generate_button: Callable = generate

@export var step_material: BaseMaterial3D

@export_group("Style", "style_")
@export var style_risers: RiserStyles = RiserStyles.OPEN ## Not yet implemented
@export var style_stringers: StringerStyles = StringerStyles.NONE ## Not yet implemented

@export var step_count: int = 3: ## Number of steps
	set(v): step_count = maxi(0,v); generate()
@export var width: float = 2.0 ## Wingspan of a step
@export var step_thickness: float = 0.08 ## Vertical thickness of a step
@export var step_depth_ratio: float = 0.85 ## How much footroom heel-toe is at each step.

@export var rise_degrees: float = 32.4: ## Informational--can't be set
	set(v): v = rad_to_deg(atan2(rise_height, rise_depth))
	get: return rad_to_deg(atan2(rise_height, rise_depth))

@export var rise_height: float = 0.178: ## Positive go up, negative go down
	set(v):
		rise_height = v; rise_degrees = 0.# setter-handled

@export var rise_depth: float = 0.28:
	set(v):
		rise_depth = v; rise_degrees = 0.# setter-handled

var _children: Array[Node] = []
var _revealed: Array[Node3D] = []

func _ready() -> void:
	if get_children().is_empty():
		generate_button.call()

func delete_all() -> void:
	if CLEAR_ALL_CHILDREN:
		for child in get_children():
			child.queue_free()
	else:
		for child in _children:
			if is_instance_valid(child):
				child.queue_free()
	_children.clear()
	_revealed.clear()
	
func add_to_scene(node: Node) -> void:
	_children.append(node)
	add_child(node)


func generate() -> void:
	if not is_inside_tree(): return
	if not Engine.is_editor_hint():
		if PREVENT_RUNTIME_REGEN: return
		push_warning("CSG regenerating at runtime")
	EditorInterface.mark_scene_as_unsaved()
	delete_all()
	
	for n in step_count:
		var pos := Vector2(rise_depth, rise_height) * (n + 1)
		var step: CSGBox3D = make_step(pos)
		_revealed.append(step)
		add_to_scene(step)
	
	for child in _revealed:
		child.owner = get_tree().edited_scene_root


func make_step(pos: Vector2) -> CSGBox3D:
	var step := CSGBox3D.new()
	step.size.x = width
	step.size.y = step_thickness
	step.size.z = step_depth_ratio * rise_depth
	step.material = step_material
	
	## just setting use_collision true handles collision on the CSGCombiner,
	## these would probably result in a doubling of collision nodes
	#if generate_collisions:
		#step.use_collision = true
		#step.collision_layer = collision_layer
		#step.collision_mask = collision_mask
	
	step.position = Vector3(0.0, pos.y, pos.x - rise_depth/2)
	return step
