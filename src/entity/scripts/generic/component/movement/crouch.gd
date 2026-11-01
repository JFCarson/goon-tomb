class_name Crouch
extends EntityComponent

## Handles crouch calculations for the entity.


# Configuration
## Keeps reference to the entity's movement configuration.
var movement_settings : EntityMovementConfig


# Process
## Initialises the component.
func initialise(controller_component : EntityController) -> void:
	super.initialise(controller_component)
	
	movement_settings = controller.entity.config.movement


# Public Interface
## Returns the target height of the entity when changing crouching state.
func calculate_height(delta : float, current_height : float, standing_height : float, crouching : bool) -> float:
	var target_height : float = standing_height
	
	if crouching:
		target_height = standing_height - movement_settings.crouch_height_reduction
	
	if target_height == standing_height and not can_stand():
		return current_height
		
	return move_toward(current_height, target_height, movement_settings.crouch_speed * delta)


## Returns whether the entity would be able to stand from crouched.
func can_stand() -> bool:
	## PLACEHOLDER: THIS NEEDS TO BE IMPLEMENTED
	return true


## Returns the movement speed multiplier applied while crouching.
func get_speed_multiplier() -> float:
	return movement_settings.crouch_multiplier
