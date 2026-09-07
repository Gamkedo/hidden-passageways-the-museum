class_name TeleportPad
extends Node3D


@export var dest_telepad: TeleportPad

@onready var teleport_area: InteractableArea = %"Teleport Area"

# var teleport_timer: Timer = Timer.new()
var rings = []

var ring_stop_height = 3
const RING_TWEEN_DURATION = 0.3
const RING_GAP = 0.8
# const RING_TWEEN_DIFF = 0.1
const DELAY_BETWEEN_RINGS = 0.2
const DELAY_AFTER_RINGS = 0.6
# const RING_ONE_MAX_HEIGHT = 3.5
# const RING_TWO_MAX_HEIGHT = RING_ONE_MAX_HEIGHT - 2
# const RING_THREE_MAX_HEIGHT = RING_TWO_MAX_HEIGHT - 2
var teleport_glow = null

var detected_player: Player

func _ready():
	# print('telepad "', name, '" ready')
	rings = [
		self.get_child(3),
		self.get_child(4),
		self.get_child(5),
	]
	
	teleport_glow = self.get_child(6)
	# duplicate the material & match all 3 pieces,
	# this way _this_ teleport pad's material stays unique,
	# but ceiling & floor will still match when material changes
	var new_teleport_material = teleport_glow.material.duplicate()
	teleport_glow.material = new_teleport_material
	teleport_glow.get_child(0).material = new_teleport_material
	teleport_glow.get_child(1).material = new_teleport_material
	new_teleport_material.albedo_color = Color(1,0,1,0)
	
	teleport_area.interaction_complete.connect(attempt_teleport)


func play_teleport_start_animation():
	# print('playing teleport animation')
	# see [tween docs](https://docs.godotengine.org/en/4.7/classes/class_tween.html)
	ring_stop_height = 3
	for ring in rings:
		# ring.show()
		create_tween().tween_property(
			ring, 
			'position', 
			Vector3(0, ring_stop_height, 0),
			RING_TWEEN_DURATION
			)
		ring_stop_height -= RING_GAP
		await get_tree().create_timer(DELAY_BETWEEN_RINGS).timeout
	
	# print('teleport_glow.material albeto_color: ', 
	# 	teleport_glow.material.albedo_color)
		
	create_tween().tween_property(
		teleport_glow.material, 
		'albedo_color', 
		Color(0, 1, 1, 1), 
		DELAY_AFTER_RINGS
	)
	#create_tween().tween_property(
	#	dest_telepad.teleport_glow.material.albedo_color, 
	#	'a', 
	#	1, 
	#	DELAY_AFTER_RINGS
	#)
	await get_tree().create_timer(DELAY_AFTER_RINGS).timeout


func play_teleport_end_animation():
	create_tween().tween_property(
		teleport_glow.material, 
		'albedo_color', 
		Color(1, 0, 1, 0), 
		DELAY_AFTER_RINGS
	)
	#create_tween().tween_property(
	#	dest_telepad.teleport_glow.material, 
	#	'albeto', 
	#	0, 
	#	DELAY_AFTER_RINGS
	#)
	await get_tree().create_timer(DELAY_AFTER_RINGS).timeout
	
	rings.reverse()
	for ring in rings:
		create_tween().tween_property(
		ring, 
		'position',
		Vector3(0, 0, 0),
		RING_TWEEN_DURATION
		)
		await get_tree().create_timer(DELAY_BETWEEN_RINGS).timeout
	
	rings.reverse() # put the rings back in proper order for next time

func attempt_teleport() -> void:
	if is_instance_valid(detected_player):
		teleport(detected_player)

func teleport(player: Player):
	# print('Teleport player: ', player.name, ' to pad ', dest_telepad.name)
	var char_controller = player.character_controller
	char_controller.movement_enabled = false
	# play a little cutscene...
	dest_telepad.play_teleport_start_animation()
	# Temporarily disable the both pad's interaction area
	teleport_area.enabled = false
	dest_telepad.teleport_area.enabled = false
	await play_teleport_start_animation()
	# end little cutscene...
	
	# actually do the teleporting
	# await get_tree().create_timer(1).timeout
	player.global_position = (dest_telepad.global_position + Vector3(0, 0.5, 0))
	char_controller.movement_enabled = true
	# teleport_glow.hide()
	# dest_telepad.teleport_glow.hide()
	
	play_teleport_end_animation()
	dest_telepad.play_teleport_end_animation()


func _on_teleport_area_body_entered(body: Node3D) -> void:
	if(body is Player):
		print('player entered telepad area')
		detected_player = body


func _on_teleport_area_body_exited(body: Node3D) -> void:
	if body is Player and body == detected_player:
		print('player left telepad area')
		detected_player = null
		# Re-enable teleport area when the player leaves the pad
		teleport_area.enabled = true
