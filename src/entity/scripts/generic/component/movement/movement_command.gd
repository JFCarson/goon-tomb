class_name EntityMovementCommand
extends RefCounted

## Contains the movement instructions for an entity during a physics tick.


# Runtime
## Direction of requested movement.
var movement_vector : Vector2 = Vector2.ZERO

## Whether the entity has requested sprinting.
var sprint : bool = false

## Whether the entity has requested jumping.
var jump : bool = false

## Whether the entity has requested crouching.
var crouch : bool = false
