class_name PlayerMovement
extends Node

## Handles horizontal movement calculations for the player.
## Receives movement context from the player controller and returns
## the resulting horizontal velocity without directly modifying the player.


# Constants
const MOVEMENT_THRESHOLD : float = 0.01
const FORWARDNESS_THRESHOLD : float = 0.5


# Configuration
@export var movement_settings : PlayerMovementSettings


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE


## Public Interface
# Updates the movement state used by this component.
func set_motion_state(state : PlayerEnums.MotionState) -> void:
	motion_state = state


# Determines whether the current input is eligible for sprinting.
func can_sprint(input_vector : Vector2, is_on_floor : bool) -> bool:
	var forwardness : float = (-input_vector.y + 1.0) / 2.0
	
	return forwardness > FORWARDNESS_THRESHOLD and not input_vector.is_zero_approx() and is_on_floor


# Calculates the player's new horizontal velocity from the supplied
# movement input and current movement state.
func calculate_horizontal_velocity(delta : float, current_velocity : Vector3, direction : Vector3, input_vector : Vector2, is_on_floor : bool) -> Vector3:
	var horizontal_velocity : Vector3 = _get_horizontal_velocity(current_velocity)
	
	if direction:
		horizontal_velocity = _apply_directional_movement(delta, horizontal_velocity, direction, input_vector, is_on_floor)
	else:
		horizontal_velocity = _apply_deceleration(delta, horizontal_velocity, is_on_floor)
	
	return horizontal_velocity


## Private Methods
# Extracts the player's horizontal velocity, ignoring vertical movement.
func _get_horizontal_velocity(current_velocity : Vector3) -> Vector3:
	return Vector3(current_velocity.x, 0.0, current_velocity.z)


# Calculates and applies directional movement based on the current input.
func _apply_directional_movement(delta : float, horizontal_velocity : Vector3, direction : Vector3, input_vector : Vector2, is_on_floor : bool) -> Vector3:
	var target_velocity : Vector3 = _calculate_target_velocity(direction, input_vector)
	
	if is_on_floor:
		return _apply_ground_acceleration(delta, horizontal_velocity, target_velocity)
	
	return _apply_air_control(delta, horizontal_velocity, direction)


# Calculates the target horizontal velocity from the desired direction and input.
func _calculate_target_velocity(direction : Vector3, input_vector : Vector2) -> Vector3:
	var speed_multiplier : float = _calculate_speed_multiplier(input_vector)
	var speed : float = movement_settings.movement_speed * speed_multiplier
	
	return direction * speed


# Calculates the movement speed multiplier based on input and motion state.
func _calculate_speed_multiplier(input_vector : Vector2) -> float:
	var forwardness : float = (-input_vector.y + 1.0) / 2.0
	var speed_multiplier : float = lerp(movement_settings.backward_speed_multiplier, 1.0, forwardness)
	
	if motion_state == PlayerEnums.MotionState.SPRINTING:
		speed_multiplier *= movement_settings.sprint_multiplier
	elif motion_state == PlayerEnums.MotionState.CROUCHING:
		speed_multiplier *= movement_settings.crouch_multiplier
	
	return speed_multiplier


# Accelerates the player towards the target velocity while grounded.
func _apply_ground_acceleration(delta : float, horizontal_velocity : Vector3, target_velocity : Vector3) -> Vector3:
	var acceleration_rate : float = _get_ground_acceleration(horizontal_velocity, target_velocity)
	
	# Snap to the target velocity when starting from rest.
	if horizontal_velocity.length_squared() < MOVEMENT_THRESHOLD:
		return target_velocity
	
	# Smoothly accelerate the player towards the target velocity.
	return horizontal_velocity.move_toward(target_velocity, acceleration_rate * delta)


# Determines the appropriate ground acceleration rate.
func _get_ground_acceleration(horizontal_velocity : Vector3, target_velocity : Vector3) -> float:
	# Increase acceleration when changing direction to make turning responsive.
	if horizontal_velocity.dot(target_velocity) < 0.0:
		return movement_settings.turn_acceleration
	
	return movement_settings.acceleration


# Applies reduced directional control while airborne.
func _apply_air_control(delta : float, horizontal_velocity : Vector3, direction : Vector3) -> Vector3:
	var control : float = movement_settings.air_movement_speed_percentage
	
	# Adjust the direction of the existing velocity without changing its magnitude.
	return horizontal_velocity.move_toward(direction * horizontal_velocity.length(), movement_settings.acceleration * control * delta)


# Decelerates the player when there is no movement input.
func _apply_deceleration(delta : float, horizontal_velocity : Vector3, is_on_floor : bool) -> Vector3:
	var control : float = _get_deceleration_control(is_on_floor)
	var deceleration : float = movement_settings.acceleration * control * delta
	
	# Decelerate each horizontal axis independently towards a complete stop.
	horizontal_velocity.x = move_toward(horizontal_velocity.x, 0.0, deceleration)
	horizontal_velocity.z = move_toward(horizontal_velocity.z, 0.0, deceleration)
	
	return horizontal_velocity


# Determines the amount of control applied while decelerating.
func _get_deceleration_control(is_on_floor : bool) -> float:
	return 1.0 if is_on_floor else movement_settings.air_movement_speed_percentage
