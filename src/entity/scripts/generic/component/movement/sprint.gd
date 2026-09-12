class_name Sprint
extends Node

## Determines whether an entity can sprint and provides its sprint speed modifier.


## Configuration
var movement_settings : EntityMovementConfig


## Public Interface
# Determines whether the entity is eligible to sprint based on its movement
# input and current movement state.
func can_sprint(movement_vector : Vector2, is_on_floor : bool) -> bool:
	if movement_vector.is_zero_approx():
		return false
	
	if not is_on_floor:
		return false
	
	var forwardness : float = (-movement_vector.y + 1.0) / 2.0
	
	return forwardness > movement_settings.forwardness_threshold


# Returns the movement speed multiplier applied while sprinting.
func get_speed_multiplier() -> float:
	return movement_settings.sprint_multiplier


## Validation
func validate() -> void:
	assert(movement_settings != null, "Sprint requires an EntityMovementConfig.")
	assert(movement_settings.sprint_multiplier > 0.0, "Sprint requires sprint_multiplier to be greater than zero.")
	assert(movement_settings.forwardness_threshold >= 0.0, "Sprint requires forwardness_threshold to be zero or greater.")
	assert(movement_settings.forwardness_threshold <= 1.0, "Sprint requires forwardness_threshold to be one or less.")
