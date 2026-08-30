class_name CameraArm
extends Node3D

## Manages camera movement and visual effects for the player.
## Receives player state from the player controller and applies
## camera-specific effects without directly controlling the player.


# Constants
const MOVEMENT_THRESHOLD : float = 0.01
const DEFAULT_HEADBOB_FREQUENCY_MULTIPLIER : float = 1.0
const HEADBOB_HORIZONTAL_FREQUENCY_DIVISOR : float = 2.0
const SWAY_CLAMP_MIN : float = -1.0
const SWAY_CLAMP_MAX : float = 1.0


# Configuration
@export var camera_settings : PlayerCameraSettings


# Node References
@onready var camera : Camera3D = $Camera
@onready var interact_ray : RayCast3D = $Camera/InteractRay
@onready var camera_default_position : Vector3 = camera.position


# Runtime State
var camera_pitch : float = 0.0
var headbob_time : float = 0.0
var headbob_position : Vector3 = Vector3.ZERO
var movement_sway : Vector3 = Vector3.ZERO
var previous_velocity : Vector3 = Vector3.ZERO


## Public Interface
# Handles mouse input for camera pitch and returns the yaw rotation
# for the player controller to apply to the player's body.
func handle_camera_motion(event : InputEvent) -> float:
	camera_pitch -= event.relative.y * camera_settings.sensitivity
	camera_pitch = clamp(camera_pitch, deg_to_rad(-camera_settings.radius), deg_to_rad(camera_settings.radius))
	rotation.x = camera_pitch
	
	# Return yaw for use by the parent.
	return -event.relative.x * camera_settings.sensitivity


# Calculates and applies all camera movement effects for the current frame.
func do_camera_movement_effects(delta : float, player_velocity : Vector3, motion_state : PlayerEnums.MotionState) -> void:
	var target_headbob_position : Vector3 = _calculate_headbob(delta, player_velocity, motion_state)
	var target_sway : Vector3 = _calculate_movement_sway(delta, player_velocity)
	
	headbob_position = headbob_position.lerp(target_headbob_position, camera_settings.headbob_reset_speed * delta)
	
	camera.position = camera_default_position + headbob_position
	
	camera.rotation.x = camera_pitch + target_sway.x
	camera.rotation.z = target_sway.z


# Returns the ray used for player interaction.
func get_interact_ray() -> RayCast3D:
	return interact_ray


## Internal Calculations
# Calculates the target positional offset produced by the headbob effect.
# Returns a neutral position when the player is stationary or airborne.
func _calculate_headbob(delta : float,player_velocity : Vector3, motion_state : PlayerEnums.MotionState) -> Vector3:
	var horizontal_speed : float = Vector2(player_velocity.x, player_velocity.z).length()
	
	if motion_state == PlayerEnums.MotionState.AIRBORNE or horizontal_speed <= MOVEMENT_THRESHOLD:
		return Vector3.ZERO
	
	var frequency_multiplier : float = DEFAULT_HEADBOB_FREQUENCY_MULTIPLIER
	
	if motion_state == PlayerEnums.MotionState.SPRINTING:
		frequency_multiplier = camera_settings.headbob_sprint_frequency_multiplier
	
	headbob_time += delta * horizontal_speed * frequency_multiplier
	
	var target_position : Vector3 = Vector3.ZERO
	
	target_position.x = cos(headbob_time * camera_settings.headbob_frequency / HEADBOB_HORIZONTAL_FREQUENCY_DIVISOR) * camera_settings.headbob_amplitude
	target_position.y = sin(headbob_time * camera_settings.headbob_frequency) * camera_settings.headbob_amplitude
	
	return target_position


# Calculates camera rotation caused by changes in player velocity.
func _calculate_movement_sway(delta : float, player_velocity : Vector3) -> Vector3:
	var horizontal_velocity : Vector3 = Vector3(player_velocity.x, 0.0, player_velocity.z)
	var previous_horizontal_velocity : Vector3 = Vector3(previous_velocity.x, 0.0, previous_velocity.z)
	
	var acceleration : Vector3 = (horizontal_velocity - previous_horizontal_velocity) / delta
	var local_acceleration : Vector3 = (global_transform.basis.inverse() * acceleration)
	
	var target_rotation : Vector3 = Vector3.ZERO
	
	target_rotation.x = -clamp(local_acceleration.z / camera_settings.movement_sway_acceleration, SWAY_CLAMP_MIN, SWAY_CLAMP_MAX) * deg_to_rad(camera_settings.movement_sway_pitch)
	target_rotation.z = -clamp(local_acceleration.x / camera_settings.movement_sway_acceleration, SWAY_CLAMP_MIN, SWAY_CLAMP_MAX) * deg_to_rad(camera_settings.movement_sway_roll)
	
	previous_velocity = player_velocity
	
	return movement_sway.lerp(target_rotation, camera_settings.movement_sway_speed * delta)
