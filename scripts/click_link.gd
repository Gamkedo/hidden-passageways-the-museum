extends Node3D

@export var url := "https://itch.io/c/188585/"

func open_link():
	OS.shell_open(url)
	JavaScriptBridge.eval("window.open('%s', '_blank');" % url)
