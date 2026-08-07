@tool
class_name Autotracklight
extends CSGCombiner3D

const PREVENT_RUNTIME_REGEN: bool = true
const CLEAR_ALL_CHILDREN: bool = true
const EMISSIVE_WHITE = preload("uid://gatwpkkuaqht")
const SPOT_LIGHT_DECAL = preload("uid://bj8ho62a7oj07")
const SPOT_LIGHT_DECAL_CROSSFADE = preload("uid://biecmslvyaivk")

static var is_editor: bool:
	get: return Engine.is_editor_hint()

## *Warning!* Destroys all children!
@export_tool_button("Generate") var generate_button := generate
#@export_tool_button("Bake") var bake_button := bake

@export_group("Track Bar", "track_")
@export var track_length: float = 3.0 ## The long side of the track bar
@export var track_height: float = 0.5 ## Vertical depth of the track bar
@export var track_width: float = 0.3 ## Horizontal thickness of the track bar
@export_range(0.0, 1.0, 0.05) var track_shoulder_ratio: float = 0.6
@export_range(0.0, 1.0, 0.05) var track_shoulder_width: float = 0.4

@export_group("Lights", "lights_")
@export_range(0, 10, 1.0, "or_greater") var lights_quantity: int = 2
@export var lights_rectangularity: float = 1.0
@export var lights_generate_spotlights: bool = true ## Generates [SpotLight3D].
@export var lights_range: float = 15.0
@export var lights_spot_angle: float = 25.0
@export var lights_energy: float = 2.0
@export var lights_color: Color = Color(0.939, 0.955, 0.961, 1.0)

@export_subgroup("Projected light quads", "projected_lights_")
## Generates quad meshes with additive light blobs for cheap fake lighting.
## If spotlights are also enabled, cross-fading is automatically applied.
## The quad mesh's look is not customizable.
@export var projected_lights_generate_quads: bool = false
@export var projected_lights_use_raycast_normal: bool = true ## Not implemented (will always face up)
@export var projected_lights_raycast_distance: float = 12.0
@export var projected_lights_scale: float = 0.9
@export var projected_lights_scale_with_distance: bool = true

@export_group("Mounting", "mount_")
@export var mount_use_raycast: bool = true
@export_flags_3d_physics var mount_raycast_mask: int = self.collision_mask
@export var mount_length: float = 5.0 ## Length of the cable going from the fixture to the ceiling, if not raycasted.
@export var mount_thickness: float = 0.04
@export var mount_track_padding: float = 0.5 ## distance from the end of the track

@export_group("Materials", "mats_")
@export var mats_track: Material
@export var mats_cable: Material

var _children: Array[Node] = []
var _revealed: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_children().is_empty():
		generate()

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

func generate() -> void:
	if not Engine.is_editor_hint():
		if PREVENT_RUNTIME_REGEN: return
		push_warning("CSG regenerating at runtime")
	EditorInterface.mark_scene_as_unsaved()
	delete_all()
	
	add_to_scene(make_track())
	
	var cable_placements: Array = [
		(mount_track_padding) / track_length,
		(track_length - mount_track_padding) / track_length
	]
	for ratio in cable_placements:
		add_to_scene(make_cable(ratio))
	
	var light_placements: Array = []
	var fraction = 1.0 / lights_quantity
	for i in lights_quantity:
		light_placements.append(
			fraction * i + (fraction/2)
		)
	for light in light_placements:
		add_to_scene(make_dot_light(light))
	
	for child in _revealed:
		child.owner = get_tree().edited_scene_root

func add_to_scene(node: Node) -> void:
	_children.append(node)
	add_child(node)


func make_track() -> CSGPolygon3D:
	var track := CSGPolygon3D.new()
	track.polygon = PackedVector2Array([
		Vector2(-track_width/2, 0.),
		Vector2(-track_width/2, track_height * track_shoulder_ratio),
		Vector2(-track_width/2*track_shoulder_width, track_height),
		Vector2(track_width/2*track_shoulder_width, track_height),
		Vector2(track_width/2, track_height * track_shoulder_ratio),
		Vector2(track_width/2, 0.),
	])
	track.depth = track_length
	track.mode = CSGPolygon3D.MODE_DEPTH
	track.material = mats_track
	
	_revealed.append(track)
	return track

func make_cable(pos_along_track: float) -> MeshInstance3D:
	var cable_length: float
	var pos: Vector3 = Vector3(0.0, track_height, -track_length * pos_along_track)
	
	if not mount_use_raycast:
		cable_length = mount_length
	else:
		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(to_global(pos), to_global(pos + Vector3.UP * 100.0), mount_raycast_mask)
		var result: Dictionary = space_state.intersect_ray(query)
		if not result:
			print("Ray didn't hit.")
			cable_length = mount_length
		else:
			var hit_pos: Vector3 = result.position
			print("Ray hit at %s." % hit_pos)
			cable_length = to_global(pos).distance_to(hit_pos)
			print("Cable length is %s." % cable_length)
	
	var mesh := BoxMesh.new()
	mesh.size = Vector3(mount_thickness, cable_length, mount_thickness)
	mesh.material = mats_cable
	
	var cable := MeshInstance3D.new()
	cable.mesh = mesh
	cable.position = pos
	cable.position.y += cable_length/2 ## height offset
	
	_revealed.append(cable)
	return cable
	
func make_dot_light(pos_along_track: float) -> CSGBox3D:
	var pos: Vector3 = Vector3(0.0, -0.08, -track_length * pos_along_track)
	
	var light: SpotLight3D
	if lights_generate_spotlights:
		## Real static lighting
		light = SpotLight3D.new()
		light.spot_range = lights_range
		light.spot_angle = lights_spot_angle
		light.spot_attenuation = 1.0
		light.light_energy = lights_energy
		light.shadow_enabled = false
		light.shadow_reverse_cull_face = true
		light.light_size = 0.05
		light.light_bake_mode = Light3D.BAKE_STATIC
		
		light.distance_fade_enabled = true
		if projected_lights_generate_quads:
			## crossfade
			light.distance_fade_begin = 10.0
			light.distance_fade_length = 5.0
		else:
			light.distance_fade_begin = 25.0
		
		light.rotation_degrees.x = -90.0
	
	var projected_light: MeshInstance3D
	if projected_lights_generate_quads:
		## Fake lighting using quads
		var projection_position: Vector3
		var _projection_normal: Vector3
		
		## Raycast to locate our light
		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(
			to_global(pos), to_global(pos + Vector3.DOWN * projected_lights_raycast_distance), mount_raycast_mask )
		var result: Dictionary = space_state.intersect_ray(query)
		if not result:
			print("Projected light quad ray didn't hit.")
			pass
		else:
			var hit_pos: Vector3 = to_local(result.position) - pos
			print("Projected light quad ray hit at %s." % hit_pos)
			
			projection_position = hit_pos
			if projected_lights_use_raycast_normal:
				_projection_normal = result.normal
			else:
				## face up
				_projection_normal = Vector3.UP
			
			var quad := QuadMesh.new()
			quad.size *= projected_lights_scale
			if projected_lights_scale_with_distance:
				quad.size *= absf(projection_position.length())
			#quad.orientation = PlaneMesh.FACE_Z ## Would use for "look_at" methods typically
			quad.orientation = PlaneMesh.FACE_Y
			
			if lights_generate_spotlights:
				quad.material = SPOT_LIGHT_DECAL_CROSSFADE
			else:
				quad.material = SPOT_LIGHT_DECAL
			
			projected_light = MeshInstance3D.new()
			projected_light.mesh = quad
			projected_light.position = projection_position
			
			#projected_light.look_at_from_position(projected_light.position, projection_normal) ## not working correctly
			projected_light.position.y += 0.01 ## bias to be above the floor
			
			_revealed.append(projected_light)
	
	var light_box := CSGBox3D.new()
	var light_thickness: float = track_width * 0.4
	light_box.size = Vector3(light_thickness, 0.25, light_thickness * lights_rectangularity)
	light_box.material = EMISSIVE_WHITE
	light_box.operation = CSGShape3D.OPERATION_SUBTRACTION
	
	light_box.position = pos
	
	if light:
		light_box.add_child(light)
		_revealed.append(light)
	
	if projected_light:
		light_box.add_child(projected_light)
		_revealed.append(projected_light)
	
	_revealed.append(light_box)
	return light_box

func bake() -> void:
	print("Bake not yet implemented")
	#var mesh: ArrayMesh = self.bake_static_mesh()
