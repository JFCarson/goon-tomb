class_name PlayerMovementSettings
extends Resource

## Configuration resource for the player's horizontal movement.
## Stores movement speeds, acceleration and airborne control parameters.



# Base movement speed while walking.
@export var movement_speed : float = 2.5

# Rate at which the player accelerates towards the target velocity, and
# decelerates to a stop.
@export var acceleration : float = 8.0

# Acceleration used when changing direction.
@export var turn_acceleration : float = 85.0

# Multiplier applied to movement speed while sprinting.
@export var sprint_multiplier : float = 2

# Multiplier applied to movement speed while moving backwards.
@export var backward_speed_multiplier : float = 0.65

# Percentage of normal movement control available while airborne.
@export var air_movement_speed_percentage : float = 0.75
