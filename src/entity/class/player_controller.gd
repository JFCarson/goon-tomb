@abstract
class_name PlayerController
extends EntityController

## Base class for value-based controllers for player entities.


# Runtime State
## Reference to the player of which this controller relates to.
var player : Player:
	get:
		return entity as Player


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	assert(entity_orchestrator is Player, "Trying to create a PlayerController on a non-player entity.")
	
	super.initialise(entity_orchestrator)
