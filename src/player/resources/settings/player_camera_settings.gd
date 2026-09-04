class_name PlayerCameraSettings
extends Resource

## Configuration resource for the player's camera behaviour.
## Stores camera look sensitivity and the parameters used by
## camera movement effects such as headbob and movement sway.


# Camera look sensitivity in radians per pixel of mouse movement.
@export var sensitivity : float = 0.002

# Maximum vertical angle the camera can look up or down from its neutral position.
@export var radius : float = 80.0


@export_group("Headbob")

# Number of headbob cycles experienced per unit of horizontal movement.
@export var headbob_frequency : float = 4.25

# Maximum positional displacement applied by the headbob effect.
@export var headbob_amplitude : float = 0.055

# Frequency multiplier applied to headbob while sprinting.
@export var headbob_sprint_frequency_multiplier : float = 0.65

# Frequency multiplier applied to headbob while crouching.
@export var headbob_crouch_frequency_multiplier : float = 0.9

# Speed at which the headbob returns to its neutral position when the player 
# stops moving or becomes airborne.
@export var headbob_reset_speed : float = 12.0


@export_group("Movement Sway")

# Horizontal acceleration required to reach the maximum movement sway.
# Higher values make the effect less sensitive to acceleration.
@export var movement_sway_acceleration : float = 95.0

# Maximum pitch rotation applied by forward and backward acceleration.
@export var movement_sway_pitch : float = 34.0

# Maximum roll rotation applied by lateral acceleration.
@export var movement_sway_roll : float = 85.0

# Speed at which movement sway interpolates towards its target rotation.
@export var movement_sway_speed : float = 0.19


@export_group("Damage Feedback")

# Maximum offset of damage feedback.
@export var damage_feedback_max_rotation : float = 0.5

# Speed at which damage feedback motion builds.
@export var damage_feedback_build_speed : float = 1.25

# Speed at which damage feedback motion resets.
@export var damage_feedback_decay_speed : float = 0.75
