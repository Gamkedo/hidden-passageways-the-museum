extends Node3D

const DEVPODS_COLLECTION := "https://itch.io/c/188585/"

@export var url: String

func open_link():
	var _url: String
	if not url.is_empty():
		_url = url
	else:
		print("Empty URL on click_link.gd node %s.
		Configure property in Inspector.
		Defaulting to DevPods Itch.io collection.")
		_url = DEVPODS_COLLECTION
	
	OS.shell_open(_url)
	JavaScriptBridge.eval("window.open('%s', '_blank');" % url)
