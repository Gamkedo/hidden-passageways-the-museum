class_name PlayerLandingAudioStream
extends AudioStreamPlayer

## Time, in milliseconds, before this sound can play again after playing.
@export var landing_sound_cooldown_MS: float = 600
## Time, in milliseconds, the body must fall for in order to trigger the sound.
## Prevents the sound from playing when falling for a very small amount of time.
@export var fall_distance_grace_period_MS: float = 300
@export var target_body: CharacterBody3D

@onready var cooldown_timer: Timer = Timer.new()
@onready var grace_period_timer: Timer = Timer.new()

var can_play: bool = true
var grace_period_passed: bool = false

var _grounded_last_frame: bool = true # Assume starting on the ground


func handle_sound_check() -> void:
	var is_grounded := target_body.is_on_floor()
	
	# If the body just touched the ground
	if is_grounded and not _grounded_last_frame:
		grace_period_timer.stop()
		play_landing_sound()
	# If the body just left the ground
	elif not is_grounded and _grounded_last_frame:
		start_grace_period_timer()
	
	# Track the grounded state for next frame
	_grounded_last_frame = is_grounded

func play_landing_sound() -> void:
	if can_play and grace_period_passed:
		#print("Audio: playing sound")
		play()
		can_play = false
		grace_period_passed = false
		start_cooldown_timer()

func start_grace_period_timer() -> void:
	#print("Audio: Starting grace period timer")
	grace_period_timer.start(fall_distance_grace_period_MS / 1000)

func start_cooldown_timer() -> void:
	#print("Audio: Starting cooldown timer")
	cooldown_timer.start(landing_sound_cooldown_MS / 1000)

func _on_grace_period_timer_timeout() -> void:
	#print("Audio: Grace period timer finished")
	grace_period_passed = true

func _on_cooldown_timer_timeout() -> void:
	#print("Audio: Cooldown timer finished")
	can_play = true

func _physics_process(_delta: float) -> void:
	handle_sound_check()

func _ready() -> void:
	cooldown_timer.one_shot = true # No looping
	cooldown_timer.autostart = false # Don't start on load
	cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS # Sync with player physics
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(cooldown_timer)
	
	grace_period_timer.one_shot = true
	grace_period_timer.autostart = false
	grace_period_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	grace_period_timer.timeout.connect(_on_grace_period_timer_timeout)
	add_child(grace_period_timer)
