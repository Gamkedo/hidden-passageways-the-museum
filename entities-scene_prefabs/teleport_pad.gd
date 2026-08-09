extends Node3D

# @export_custom(0, 'Target pad id')
# var goto_telepad := 0
@export var dest_telepad: Node3D

# @export_custom(0, "This pad's id")
# var pad_id := 0

func _ready():
	# print('telepad "', name, '" ready')
	pass

func teleport(player):
	print('Teleport player: ', player.name, ' to pad ', dest_telepad.name)
	player.global_position = (dest_telepad.global_position + Vector3(0, 2, 0))
	
	
	
	
	
