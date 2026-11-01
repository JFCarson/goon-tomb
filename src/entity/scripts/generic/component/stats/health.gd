@tool
class_name Health
extends EntityStat

## Manages an entity's health, and provides an API to manipulate it.


# Public Interface
## Processes a damage instance for the entity, returning the new total amount
## of health.
func damage(amount : float) -> float:
	if amount > 0.0:
		current -= amount
		
	return current	


## Processes a heal instance for the entity, returning the new total amount of
## health.
func heal(amount : float) -> float:
	if amount > 0.0:
		current += amount
		
	return current
