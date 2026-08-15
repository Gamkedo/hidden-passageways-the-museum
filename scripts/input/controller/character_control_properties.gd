class_name CharacterControlProperties
extends Resource

@export_category("Movement")
@export_subgroup("Velocity")
@export_range(0, 100) var max_velocity: float = 7

@export_subgroup("Acceleration")
@export_range(0, 100) var acceleration_rate: float = 20
@export_range(0, 100) var decceleration_rate: float = 15

@export_subgroup("Sprint")
@export_range(0, 100) var max_sprint_velocity: float = 10

@export_range(0, 100) var sprint_acceleration_rate: float = 25
@export_range(0, 100) var sprint_decceleration_rate: float = 18

@export_category("Jump")
@export_range(0, 100) var jump_velocity: float = 5
@export_range(0, 100) var max_air_velocity: float = 8
@export_range(0, 100) var air_acceleration: float = 10
@export_range(0, 100) var air_decceleration: float = 8
@export_range(0, 100) var max_air_jumps: int = 0
## Number of frames after transitioning from Grounded to Airbone that the player can still jump
@export_range(0, 100) var coyote_frames: int = 15

@export_category("Flight")
@export_range(0, 100) var max_flight_velocity: float = 15
@export_range(0, 100) var flight_acceleration: float = 30
@export_range(0, 100) var flight_decceleration: float = 50


@export_category("Stair Step (Mantle)")
## How much the character body is moved upwards when attempting to stair step
@export_range(0, 100) var stair_step_strength: float = 7
