class_name EntityStateConfig
extends Resource

## Configuration for an entity's game state.


# Defines a list of state components tracked by the entity, allowing an
# EntityStateController to dynamically handle the creation and management of
# each state.
@export var tracked_states : Array[EntityStateEnums.States]
