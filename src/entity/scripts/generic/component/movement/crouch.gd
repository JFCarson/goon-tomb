class_name Crouch
extends Node

## Handles crouch calculations for the entity.


# Configuration
var movement_settings : EntityMovementConfig


# Public Interface
# Returns the movement speed multiplier applied while crouching.
func get_speed_multiplier() -> float:
	return movement_settings.crouch_multiplier


# Returns the target height of the entity's collision while crouching.
func get_target_height(standing_height : float) -> float:
	return standing_height - movement_settings.crouch_height_reduction


# Calculates the target height of the the entity when
func calculate_height(delta : float, current_height : float, standing_height : float, crouching : bool) -> float:
	var target_height : float = standing_height

	if crouching:
		target_height -= movement_settings.crouch_height_reduction

	return move_toward(current_height, target_height, movement_settings.crouch_speed * delta)
