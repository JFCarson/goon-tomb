class_name CameraSway
extends Node

## Calculates rotational camera sway from changes in player movement.


## Configuration
var config : PlayerConfig


## Runtime State
var previous_velocity : Vector3 = Vector3.ZERO
var sway_rotation : Vector3 = Vector3.ZERO


## Public Interface
# Calculates the current camera sway rotation for the player.
func calculate(delta : float, player_velocity : Vector3, camera_basis : Basis) -> Vector3:
	var target_rotation : Vector3 = _calculate_target_rotation(delta, player_velocity, camera_basis)
	
	sway_rotation = _interpolate_rotation(delta, target_rotation)
	
	return sway_rotation


## Internal Calculations
# Calculates the target rotation produced by changes in player velocity.
func _calculate_target_rotation(delta : float, player_velocity : Vector3, camera_basis : Basis) -> Vector3:
	var acceleration : Vector3 = _calculate_acceleration(delta, player_velocity)
	var local_acceleration : Vector3 = _convert_to_local_acceleration(acceleration, camera_basis)
	
	previous_velocity = player_velocity
	
	return _calculate_sway_rotation(local_acceleration)


# Calculates horizontal acceleration from the player's change in velocity.
func _calculate_acceleration(delta : float, player_velocity : Vector3) -> Vector3:
	if delta <= 0.0:
		return Vector3.ZERO
	
	var horizontal_velocity : Vector3 = Vector3(player_velocity.x, 0.0, player_velocity.z)
	var previous_horizontal_velocity : Vector3 = Vector3(previous_velocity.x, 0.0, previous_velocity.z)
	
	return (horizontal_velocity - previous_horizontal_velocity) / delta


# Converts world-space acceleration into camera-local space.
func _convert_to_local_acceleration(acceleration : Vector3, camera_basis : Basis) -> Vector3:
	return camera_basis.inverse() * acceleration


# Calculates the target pitch and roll produced by local acceleration.
func _calculate_sway_rotation(local_acceleration : Vector3) -> Vector3:
	var target_rotation : Vector3 = Vector3.ZERO
	
	target_rotation.x = _calculate_pitch(local_acceleration.z)
	target_rotation.z = _calculate_roll(local_acceleration.x)
	
	return target_rotation


# Calculates the target pitch produced by forward and backward acceleration.
func _calculate_pitch(acceleration : float) -> float:
	var sway_amount : float = clamp(acceleration / config.camera.movement_sway_acceleration, -1.0, 1.0)
	
	return -sway_amount * deg_to_rad(config.camera.movement_sway_pitch)


# Calculates the target roll produced by sideways acceleration.
func _calculate_roll(acceleration : float) -> float:
	var sway_amount : float = clamp(acceleration / config.camera.movement_sway_acceleration, -1.0, 1.0)
	
	return -sway_amount * deg_to_rad(config.camera.movement_sway_roll)


# Smoothly moves the current sway rotation towards its target.
func _interpolate_rotation(delta : float, target_rotation : Vector3) -> Vector3:
	var interpolation_amount : float = clamp(config.camera.movement_sway_speed * delta, 0.0, 1.0)
	
	return sway_rotation.lerp(target_rotation, interpolation_amount)


## Validation
func validate() -> void:
	assert(config != null, "CameraSway requires a PlayerConfig.")
	assert(config.camera != null, "CameraSway requires a PlayerCameraConfig.")
	assert(config.camera.movement_sway_acceleration > 0.0, "CameraSway requires movement_sway_acceleration to be greater than zero.")
	assert(config.camera.movement_sway_speed > 0.0, "CameraSway requires movement_sway_speed to be greater than zero.")
	assert(config.camera.movement_sway_pitch >= 0.0, "CameraSway requires movement_sway_pitch to be zero or greater.")
	assert(config.camera.movement_sway_roll >= 0.0, "CameraSway requires movement_sway_roll to be zero or greater.")
