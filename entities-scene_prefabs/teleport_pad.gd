extends Node3D

# @export_custom(0, 'Target pad id')
# var goto_telepad := 0
@export var dest_telepad: Node3D

signal interaction_available
signal interaction_unavailable

var player_in_teleport_area = false
# @export_custom(0, "This pad's id")
# var pad_id := 0

func _ready():
	# print('telepad "', name, '" ready')
	pass

func teleport(player):
	print('Teleport player: ', player.name, ' to pad ', dest_telepad.name)
	player.global_position = (dest_telepad.global_position + Vector3(0, 2, 0))

func _on_teleport_area_body_entered(body: Node3D) -> void:
	print('player entered telepad area')
	player_in_teleport_area = true
	interaction_available.emit(self)


func _on_teleport_area_body_exited(body: Node3D) -> void:
	print('player left telepad area')
	player_in_teleport_area = false
	interaction_unavailable.emit()
