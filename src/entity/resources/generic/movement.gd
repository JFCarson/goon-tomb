class_name EntityMovementConfig
extends Resource

## Configuration for an entity's movement.


# Base movement speed while walking.
@export var movement_speed : float = 2.5

# Base jump height for the entity.
@export var jump_height : float = 7.5


@export_group("Acceleration")
# Rate at which the entity accelerates towards its target velocity.
# Also used as the base rate for decelerating to a stop.
@export var acceleration : float = 8.0

# Acceleration used when the entity changes direction.
# A higher value makes direction changes feel more responsive.
@export var turn_acceleration : float = 105.0


@export_group("Speed Multipliers")
# Multiplier applied to movement speed while in standard movement state
@export var walk_multiplier : float = 1.0

# Multiplier applied to movement speed while sprinting.
@export var sprint_multiplier : float = 2.0

# Multiplier applied to movement speed while crouching.
@export var crouch_multiplier : float = 0.8

# Multiplier applied to movement speed while moving backwards.
@export var backward_multiplier : float = 0.65

# Multiplier applied to normal movement control while airborne.
# Lower values reduce how strongly movement input can change horizontal
# velocity while the entity is in the air.
@export var air_movement_control_multiplier : float = 2.5


@export_group("Crouching")
# Determines how much the player's height is reduced by when crouching.
@export var crouch_height_reduction : float = 0.75

# Determines how fast the player's height is reduced/increased when 
# crouching/standing.
@export var crouch_speed : float = 2.0


@export_group("Config")
# Minimum horizontal velocity magnitude used when determining whether
# the entity is considered effectively stationary.
@export var movement_threshold : float = 0.01

# Minimum forward movement required for actions that require the entity
# to be moving predominantly forwards, such as sprinting.
@export var forwardness_threshold : float = 0.5
