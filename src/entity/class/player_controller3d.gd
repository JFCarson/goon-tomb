@abstract
class_name PlayerController3D
extends EntityController3D

## Base class for 3D space-based controllers for player entities.


# Runtime State
## Reference to the player of which this controller relates to.
var player : Player:
	get:
		return entity as Player


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	assert(entity_orchestrator is Player, "Trying to create a PlayerController3D on a non-player entity.")
	
	super.initialise(entity_orchestrator)
