@abstract
class_name EntityController3D
extends Node3D

## Base class for 3D space-based controllers for entities.


# Runtime State
## Reference to the entity of which this controller relates to.
var entity : CharacterEntity


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	entity = entity_orchestrator
