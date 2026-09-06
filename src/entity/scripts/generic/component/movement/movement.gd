class_name Movement
extends Node

## Calculates horizontal movement for an entity.


# Configuration
var movement_settings : EntityMovementConfig


## Public Interface
# Calculates the entity's resulting horizontal velocity based on its
# current velocity, desired movement direction, movement input, and
# whether it is grounded.
#
# The component does not modify the entity directly; it returns the
# calculated horizontal velocity for the caller to apply.
func calculate_velocity(delta : float, current_velocity : Vector3, direction : Vector3, input_vector : Vector2, speed_multiplier : float, is_on_floor : bool) -> Vector3:
	var horizontal_velocity := Vector3(current_velocity.x, 0.0, current_velocity.z)

	# If there is no movement input, gradually decelerate towards a stop.
	if direction.is_zero_approx():
		return _apply_deceleration(delta, horizontal_velocity, is_on_floor)

	# Calculate the desired horizontal velocity from the movement direction
	# and configured movement speed.
	var target_velocity := _calculate_target_velocity(direction, input_vector, speed_multiplier)

	# Ground movement uses acceleration towards the target velocity.
	if is_on_floor:
		return _apply_ground_acceleration(delta, horizontal_velocity, target_velocity)

	# Airborne movement uses reduced air control rather than ground acceleration.
	return _apply_air_control(delta, horizontal_velocity, direction)


## Private Methods
# Calculates the desired horizontal velocity from movement direction
# and input-dependent speed modifiers.
func _calculate_target_velocity(direction : Vector3, input_vector : Vector2, speed_multiplier : float) -> Vector3:
	var movement_speed : float = movement_settings.movement_speed
	var directional_multiplier : float = _calculate_directional_speed_multiplier(input_vector)
	var final_speed : float = movement_speed * speed_multiplier * directional_multiplier
	
	return direction * final_speed


# Calculates the movement speed multiplier based on how far the input
# is oriented away from forward movement.
func _calculate_directional_speed_multiplier(input_vector : Vector2) -> float:
	var forwardness : float = (-input_vector.y + 1.0) / 2.0
	
	return lerp(movement_settings.backward_multiplier, 1.0, forwardness)


# Accelerates the entity's horizontal velocity towards its desired
# ground movement velocity.
func _apply_ground_acceleration(delta : float, horizontal_velocity : Vector3, target_velocity : Vector3) -> Vector3:
	var acceleration_rate : float = _get_ground_acceleration(horizontal_velocity, target_velocity)
	
	if horizontal_velocity.length_squared() < movement_settings.movement_threshold:
		return target_velocity
	
	return horizontal_velocity.move_toward(target_velocity, acceleration_rate * delta)


# Determines the acceleration rate used for ground movement.
func _get_ground_acceleration(horizontal_velocity : Vector3, target_velocity : Vector3) -> float:
	if horizontal_velocity.dot(target_velocity) < 0.0:
		return movement_settings.turn_acceleration
	
	return movement_settings.acceleration


# Applies directional control while the entity is airborne.
func _apply_air_control(delta : float, horizontal_velocity : Vector3, direction : Vector3) -> Vector3:
	var control_amount : float = movement_settings.air_movement_control_multiplier
	
	return horizontal_velocity.move_toward(direction * horizontal_velocity.length(), movement_settings.acceleration * control_amount * delta)


# Gradually reduces horizontal velocity towards zero.
func _apply_deceleration(delta : float, horizontal_velocity : Vector3, is_on_floor : bool) -> Vector3:
	var control_amount : float = 1.0
	
	if not is_on_floor:
		control_amount *= movement_settings.air_movement_control_multiplier
	
	var deceleration : float = movement_settings.acceleration * control_amount * delta
	
	horizontal_velocity.x = move_toward(horizontal_velocity.x, 0.0, deceleration)
	horizontal_velocity.z = move_toward(horizontal_velocity.z, 0.0, deceleration)
	
	return horizontal_velocity
