class_name PlayerMovementSettings
extends Resource

## Configuration resource for the player's horizontal movement.
## Stores movement speeds, acceleration and airborne control parameters.



# Base movement speed while walking.
@export var movement_speed : float = 3.0

# Rate at which the player accelerates towards the target velocity.
@export var acceleration : float = 20.0

# Acceleration used when changing direction.
@export var turn_acceleration : float = 150.0

# Multiplier applied to movement speed while sprinting.
@export var sprint_multiplier : float = 2

# Multiplier applied to movement speed while moving backwards.
@export var backward_speed_multiplier : float = 0.65

# Percentage of normal movement control available while airborne.
@export var air_movement_speed_percentage : float = 0.35
