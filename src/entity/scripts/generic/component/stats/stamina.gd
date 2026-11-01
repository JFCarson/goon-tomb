@tool
class_name Stamina
extends EntityStat

## Manages an entity's stamina, and provides an API to manipulate it.


# Public Interface
## Spends stamina if the entity has enough, returning the success as a bool.
func spend(amount : float) -> bool:
	var success : bool = false
	
	if has_at_least(amount):
		current -= amount
		stats_controller.stamina_regeneration.restart_delay_timer()
		success = true
		
	return success
