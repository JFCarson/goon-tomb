class_name Sprint
extends EntityComponent

## Determines whether an entity can sprint and provides its sprint speed modifier.


# Configuration
## Keeps reference to the entity's movement configuration.
var movement_settings : EntityMovementConfig


# Process
## Initialises the component.
func initialise(controller_component : EntityController) -> void:
	super.initialise(controller_component)
	
	movement_settings = controller.entity.config.movement


# Public Interface
## Determines whether the entity is eligible to sprint.
func can_sprint(movement_vector) -> bool:
	if movement_vector.is_zero_approx():
		return false
	
	if not controller.entity.is_on_floor():
		return false
	
	if not controller.entity.resource.can_afford_sprint():
		return false
	
	var forwardness : float = (-movement_vector.y + 1.0) / 2.0
	
	return forwardness > movement_settings.forwardness_threshold


## Returns the movement speed multiplier applied while sprinting.
func get_speed_multiplier() -> float:
	return movement_settings.sprint_multiplier
