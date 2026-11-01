class_name Movement
extends EntityComponent

## Calculates horizontal movement for an entity.


# Configuration
## Keeps reference to the entity's movement configuration.
var movement_settings : EntityMovementConfig


# Process
## Initialises the component.
func initialise(controller_component : EntityController) -> void:
	super.initialise(controller_component)
	
	movement_settings = controller.entity.config.movement


# Public Interface
## Calculates the entity's resulting horizontal velocity based on its current 
## velocity, desired movement direction, movement input, and whether it is grounded.
func calculate_velocity(delta : float, current_velocity : Vector3, direction : Vector3, input_vector : Vector2, speed_multiplier : float) -> Vector3:
	var horizontal_velocity := Vector3(current_velocity.x, 0.0, current_velocity.z)
	
	# If there is no movement input, gradually decelerate towards a stop.
	if direction.is_zero_approx():
		return _apply_deceleration(delta, horizontal_velocity)
	
	# Ground movement uses acceleration towards the target velocity.
	if controller.entity.is_on_floor():
		return _apply_ground_acceleration(delta, horizontal_velocity, _calculate_target_velocity(direction, input_vector, speed_multiplier))
	
	# Airborne movement uses reduced air control rather than ground acceleration.
	return _apply_air_control(delta, horizontal_velocity, direction)


# Private Methods
## Calculates the desired horizontal velocity from movement direction and 
## input-dependent speed modifiers.
func _calculate_target_velocity(direction : Vector3, input_vector : Vector2, speed_multiplier : float) -> Vector3:
	var final_speed : float = movement_settings.movement_speed * speed_multiplier * _calculate_directional_speed_multiplier(input_vector)
	
	return direction * final_speed


## Calculates the movement speed multiplier based on how far the input is oriented 
## away from forward movement.
func _calculate_directional_speed_multiplier(input_vector : Vector2) -> float:
	var forwardness : float = (-input_vector.y + 1.0) / 2.0
	
	return lerp(movement_settings.backward_multiplier, 1.0, forwardness)


## Accelerates the entity's horizontal velocity towards its desired ground 
## movement velocity.
func _apply_ground_acceleration(delta : float, horizontal_velocity : Vector3, target_velocity : Vector3) -> Vector3:
	if horizontal_velocity.length_squared() < movement_settings.movement_threshold:
		return target_velocity
	
	return horizontal_velocity.move_toward(target_velocity, _get_ground_acceleration(horizontal_velocity, target_velocity) * delta)


## Determines the acceleration rate used for ground movement.
func _get_ground_acceleration(horizontal_velocity : Vector3, target_velocity : Vector3) -> float:
	if horizontal_velocity.dot(target_velocity) < 0.0:
		return movement_settings.turn_acceleration
	
	return movement_settings.acceleration


## Applies directional control while the entity is airborne.
func _apply_air_control(delta : float, horizontal_velocity : Vector3, direction : Vector3) -> Vector3:
	var acceleration : float = movement_settings.acceleration * movement_settings.air_movement_control_multiplier
	
	return horizontal_velocity.move_toward(direction * horizontal_velocity.length(), acceleration * delta)


## Gradually reduces horizontal velocity towards zero.
func _apply_deceleration(delta : float, horizontal_velocity : Vector3) -> Vector3:
	var control_amount : float = 1.0
	
	if not controller.entity.is_on_floor():
		control_amount *= movement_settings.air_movement_control_multiplier
	
	var deceleration : float = movement_settings.acceleration * control_amount * delta
	
	horizontal_velocity.x = move_toward(horizontal_velocity.x, 0.0, deceleration)
	horizontal_velocity.z = move_toward(horizontal_velocity.z, 0.0, deceleration)
	
	return horizontal_velocity
