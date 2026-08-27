extends Node3D


@export var dest_telepad: Node3D

# var teleport_timer: Timer = Timer.new()
var rings = []

var ring_stop_height = 3
const RING_TWEEN_DURATION = 0.3
const RING_GAP = 0.8
# const RING_TWEEN_DIFF = 0.1
const DELAY_BETWEEN_RINGS = 0.2
const DELAY_AFTER_RINGS = 10.6
# const RING_ONE_MAX_HEIGHT = 3.5
# const RING_TWO_MAX_HEIGHT = RING_ONE_MAX_HEIGHT - 2
# const RING_THREE_MAX_HEIGHT = RING_TWO_MAX_HEIGHT - 2

func _ready():
	# print('telepad "', name, '" ready')
	rings = [
		self.get_child(3),
		self.get_child(4),
		self.get_child(5),
	]
	pass
	
func get_char_controller(player):
	var char_controller = player.get_child(2)
	if(char_controller is CharacterController):
		return char_controller
	else:
		push_error("Cannot find character controller on player: ", player)
		return null

func play_teleport_start_animation():
	# print('playing teleport animation')
	# see [tween docs](https://docs.godotengine.org/en/4.7/classes/class_tween.html)
	ring_stop_height = 3
	for ring in rings:
		ring.show()
		create_tween().tween_property(
			ring, 
			'position', 
			Vector3(0, ring_stop_height, 0),
			RING_TWEEN_DURATION
			)
		ring_stop_height -= RING_GAP
		await get_tree().create_timer(DELAY_BETWEEN_RINGS).timeout
	
	await get_tree().create_timer(DELAY_AFTER_RINGS).timeout
	pass

func teleport(player):
	# print('Teleport player: ', player.name, ' to pad ', dest_telepad.name)
	var char_controller = get_char_controller(player)
	char_controller.movement_enabled = false
	# play a little cutscene...
	await play_teleport_start_animation()
	# end little cutscene...
	
	# actually do the teleporting
	# await get_tree().create_timer(1).timeout
	player.global_position = (dest_telepad.global_position + Vector3(0, 0.5, 0))
	char_controller.movement_enabled = true
	
	# TODO: ending cutscene
	for ring in rings:
		ring.position = Vector3(0,0,0)
		# ring.hide()

func _on_teleport_area_body_entered(body: Node3D) -> void:
	if(body.name == "Player with UI"):
		# print('player entered telepad area')
		var char_controller = get_char_controller(body)
		char_controller.entered_teleport_pad_area(self)


func _on_teleport_area_body_exited(body: Node3D) -> void:
	if(body.name == "Player with UI"):
		print('player left telepad area')
		var char_controller = get_char_controller(body)
		char_controller.exited_teleport_pad_area()
