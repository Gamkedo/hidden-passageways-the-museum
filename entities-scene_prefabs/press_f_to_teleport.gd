extends RichTextLabel

func _ready():
	pass
	

func _process(_delta):
	var char_controller = self.get_parent().get_parent().get_child(2)
	if(char_controller is not CharacterController):
		push_error('Could not find character controller')
		pass
	
	var recently_teleported = char_controller.recently_teleported
	var on_teleport_pad = char_controller.on_teleport_pad
	
	if(visible && (recently_teleported || !on_teleport_pad)):
		hide()
		pass
	
	if(!visible && on_teleport_pad && !recently_teleported):
		show()
		pass
