class_name Jump
extends EntityComponent

## Handles jump calculations for the player.


# Configuration
## Keeps reference to the entity's movement configuration.
var movement_settings : EntityMovementConfig


# Process
## Initialises the component.
func initialise(controller_component : EntityController) -> void:
	super.initialise(controller_component)
	
	movement_settings = controller.entity.config.movement


# Public Interface
## Determines whether the entity is eligible to jump.
func can_jump() -> bool:
	if not controller.entity.is_on_floor():
		return false
		
	if not controller.entity.resource.can_afford_jump():
		return false 
	
	if controller.entity.state.check(EntityStateEnums.States.MOTION) == EntityStateEnums.Motion.CROUCHING:
		return false
	
	return true


## Calculates the vertical velocity required to reach the configured jump height.
func calculate_jump_velocity() -> float:
	return sqrt(2.0 * movement_settings.jump_height)
