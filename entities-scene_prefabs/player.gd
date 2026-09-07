class_name Player
extends CharacterBody3D

@onready var ui_layer: CanvasLayer = %UILayer
@onready var interact_prompt_panel: InteractPromptPanel = %InteractPromptPanel
@onready var interact_prompt_text: Label = %InteractPromptText
@onready var page_text_panel: PageTextPanel = %PageTextPanel

@onready var character_controller: CharacterController = %CharacterController

@onready var body_cam: Camera3D = %BodyCam
