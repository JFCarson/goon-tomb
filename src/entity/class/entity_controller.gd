@abstract
class_name EntityController
extends Node

## Base class for value-based controllers for entities.


# Runtime State
## Reference to the entity of which this controller relates to.
var entity : CharacterEntity


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	entity = entity_orchestrator
