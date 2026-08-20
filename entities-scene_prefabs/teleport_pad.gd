extends Node3D


@export var dest_telepad: Node3D

func _ready():
	# print('telepad "', name, '" ready')
	pass

func teleport(player):
	# print('Teleport player: ', player.name, ' to pad ', dest_telepad.name)
	player.global_position = (dest_telepad.global_position + Vector3(0, 2, 0))

func _on_teleport_area_body_entered(body: Node3D) -> void:
	if(body.name == "Player with UI"):
		# print('player entered telepad area')
		var char_controller = body.get_child(2)
		if(char_controller is CharacterController):
			char_controller.entered_teleport_pad_area(self)
		else:
			push_error("Cannot find character controller on player: ", body)


func _on_teleport_area_body_exited(body: Node3D) -> void:
	if(body.name == "Player with UI"):
		print('player left telepad area')
		var char_controller = body.get_child(2)
		if(char_controller is CharacterController):
			char_controller.exited_teleport_pad_area()
		else:
			push_error("Cannot find character controller on player: ", body)
