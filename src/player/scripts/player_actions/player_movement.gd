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
	# Extract the current horizontal velocity, ignoring vertical movement.
	var horizontal_velocity : Vector3 = Vector3(current_velocity.x, 0.0, current_velocity.z)
	
	if direction:
		# Calculate how much the input is biased towards moving forwards.
		# This produces 0.0 for fully backwards and 1.0 for fully forwards.
		var forwardness : float = (-input_vector.y + 1.0) / 2.0
		
		# Interpolate the movement speed based on the forward/backward input.
		var speed_multiplier : float = lerp(movement_settings.backward_speed_multiplier, 1.0, forwardness)
		
		# Override the directional speed when sprinting.
		if motion_state == PlayerEnums.MotionState.SPRINTING:
			speed_multiplier = movement_settings.sprint_multiplier
		
		# Calculate the target horizontal velocity from the desired direction and speed.
		var speed : float = movement_settings.movement_speed * speed_multiplier
		var target_velocity : Vector3 = direction * speed
		
		if is_on_floor:
			# Use the normal acceleration rate unless the player is reversing direction.
			var acceleration_rate : float = movement_settings.acceleration
			
			# Increase acceleration when changing direction to make turning responsive.
			if horizontal_velocity.dot(target_velocity) < 0.0:
				acceleration_rate = movement_settings.turn_acceleration
			
			# Snap to the target velocity when starting from rest.
			if horizontal_velocity.length_squared() < MOVEMENT_THRESHOLD:
				horizontal_velocity = target_velocity
			else:
				# Smoothly accelerate the player towards the target velocity.
				horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration_rate * delta)
		else:
			# Reduce directional control while airborne.
			var control : float = movement_settings.air_movement_speed_percentage
			
			# Adjust the direction of the existing velocity without changing its magnitude.
			horizontal_velocity = horizontal_velocity.move_toward(direction * horizontal_velocity.length(), movement_settings.acceleration * control * delta)
	else:
		# When there is no movement input, use reduced control while airborne.
		var control : float = 1.0 if is_on_floor else movement_settings.air_movement_speed_percentage
		
		# Decelerate each horizontal axis independently towards a complete stop.
		horizontal_velocity.x = move_toward(horizontal_velocity.x, 0.0, movement_settings.acceleration * control * delta)
		horizontal_velocity.z = move_toward(horizontal_velocity.z, 0.0, movement_settings.acceleration * control * delta)
	
	return horizontal_velocity
