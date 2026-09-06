class_name CameraBob
extends Node

## Calculates positional camera bob from player movement.


# Configuration
var config : PlayerConfig
var state : EntityStateController


# Runtime
var headbob_time : float = 0.0
var headbob_position : Vector3 = Vector3.ZERO


## Public Interface
# Calculates the current headbob position for the player.
func calculate(delta : float, player_velocity : Vector3) -> Vector3:
	var target_position : Vector3 = _calculate_target_position(delta, player_velocity)
	
	headbob_position = _interpolate_position(delta, target_position)
	
	return headbob_position


## Internal Calculations
# Calculates the target position produced by the player's current movement.
func _calculate_target_position(delta : float, player_velocity : Vector3) -> Vector3:
	var horizontal_speed : float = _get_horizontal_speed(player_velocity)
	
	if _should_reset(horizontal_speed):
		return Vector3.ZERO
	
	var frequency_multiplier : float = _get_frequency_multiplier()
	
	headbob_time += delta * horizontal_speed * frequency_multiplier
	
	return _calculate_bob_position()


# Returns the player's horizontal movement speed.
func _get_horizontal_speed(player_velocity : Vector3) -> float:
	return Vector2(player_velocity.x, player_velocity.z).length()


# Returns whether the headbob should return to its neutral position.
func _should_reset(horizontal_speed : float) -> bool:
	if state.check(EntityStateEnums.States.MOTION) == EntityStateEnums.Motion.AIRBORNE:
		return true
	
	return horizontal_speed <= config.movement.movement_threshold


# Returns the headbob frequency multiplier for the current movement state.
func _get_frequency_multiplier() -> float:
	var frequency_multiplier : float = config.camera.default_headbob_frequency_multiplier
	
	if state.check(EntityStateEnums.States.MOTION) == EntityStateEnums.Motion.SPRINTING:
		frequency_multiplier *= config.camera.headbob_sprint_frequency_multiplier
	elif state.check(EntityStateEnums.States.MOTION) == EntityStateEnums.Motion.CROUCHING:
		frequency_multiplier *= config.camera.headbob_crouch_frequency_multiplier
	
	return frequency_multiplier


# Calculates the positional offset produced by the current headbob cycle.
func _calculate_bob_position() -> Vector3:
	var bob_position : Vector3 = Vector3.ZERO
	
	bob_position.x = cos(headbob_time * config.camera.headbob_frequency / config.camera.headbob_horizontal_frequency_divisor) * config.camera.headbob_amplitude
	bob_position.y = sin(headbob_time * config.camera.headbob_frequency) * config.camera.headbob_amplitude
	
	return bob_position


# Smoothly moves the current headbob position towards its target.
func _interpolate_position(delta : float, target_position : Vector3) -> Vector3:
	return headbob_position.lerp(target_position, config.camera.headbob_reset_speed * delta)
