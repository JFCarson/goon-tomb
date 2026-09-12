class_name GameCameraConfig
extends Resource

## Configuration for the player's game camera.


# Camera look sensitivity in radians per pixel of mouse movement.
# Higher values make the camera rotate further for the same mouse movement,
# making the camera feel faster/more responsive.
@export var sensitivity : float = 0.002

# Maximum vertical look angle in degrees from the camera's neutral position.
# This limits how far the player can look up or down.
# Higher values allow a greater vertical look range.
@export var pitch_limit : float = 80.0

# Minimum movement speed/velocity required before movement-based camera
# effects (such as head bob/sway) are considered active.
# Increasing this means the player must move faster before the camera reacts.
@export var effects_movement_threshold : float = 0.01


@export_group("Headbob")
# Maximum positional displacement produced by the headbob effect.
# Controls how far the camera moves away from its neutral position during each 
# mheadbob cycle.
# Higher values make the headbob more pronounced and physically noticeable.
@export var headbob_amplitude : float = 0.055

# Base frequency of the headbob effect while moving normally.
# Determines how quickly the headbob oscillates as the player moves.
# Higher values produce faster, more frequent bobbing.
@export var headbob_frequency : float = 4.25

# Multiplier applied to the base head-bob frequency.
# Higher values make the head bob oscillate faster; lower values make it slower.
# This is a multiplier rather than the actual frequency, allowing the base
# frequency to be modified elsewhere while retaining a default.
@export var default_headbob_frequency_multiplier : float = 1.0

# Multiplier applied to the base headbob frequency while sprinting.
# Values above 1.0 make sprinting produce faster headbob than normal movement,
# while values below 1.0 make sprinting produce slower headbob.
@export var headbob_sprint_frequency_multiplier : float = 0.65

# Multiplier applied to the base headbob frequency while crouching.
# Values above 1.0 make crouching produce faster headbob than normal movement,
# while values below 1.0 make crouching produce slower headbob.
@export var headbob_crouch_frequency_multiplier : float = 0.9

# Divisor used when calculating the horizontal component of the head-bob.
# A larger value reduces the horizontal oscillation frequency relative to the
# vertical bob, making the camera move horizontally less frequently.
@export var headbob_horizontal_frequency_divisor : float = 2.0

# Speed at which the camera returns to its neutral position when headbob
# should no longer be active, such as when the player stops moving or leaves
# the ground.
# Higher values make the reset happen more quickly and sharply.
# Lower values make the camera settle back to neutral more slowly and smoothly.
@export var headbob_reset_speed : float = 12.0


@export_group("Movement Sway")
# Horizontal acceleration required to produce maximum movement sway.
# The player's acceleration is compared against this value to determine
# how strongly the camera should tilt.
# Higher values require more sudden movement before maximum sway is reached,
# making the effect less sensitive.
@export var movement_sway_acceleration : float = 95.0

# Maximum pitch rotation produced by forward/backward acceleration.
# Controls how far the camera tilts forward or backward when the player
# accelerates or decelerates.
# Higher values make forward/backward movement feel more exaggerated.
@export var movement_sway_pitch : float = 34.0

# Maximum roll rotation produced by lateral acceleration.
# Controls how far the camera tilts left or right when the player
# accelerates sideways or changes direction.
# Higher values make strafing and lateral direction changes feel more physical.
@export var movement_sway_roll : float = 85.0

# Speed at which movement sway interpolates towards its target rotation.
# Higher values make the camera catch up to the target sway more quickly,
# producing a sharper and more responsive effect.
@export var movement_sway_speed : float = 0.19

# Lower bound for the calculated movement sway value.
# Prevents the sway from producing values below the value, which limits the 
# maximum amount of camera displacement/rotation in the negative direction.
@export var sway_clamp_minimum : float = -1.0

# Upper bound for the calculated movement sway value.
# Prevents the sway from producing values above the value, which limits the 
# maximum amount of camera displacement/rotation in the positive direction.
@export var sway_clamp_maximum : float = 1.0


@export_group("Damage Feedback")
# Minumum & maximum rotation applied by the damage feedback effect.
# Determines the greatest amount the camera can rotate when reacting to damage.
# Higher values make getting hit feel more impactful and disorienting.
@export var damage_feedback_min_rotation : float = 7.5
@export var damage_feedback_max_rotation : float = 25.0

# Speed at which damage feedback builds towards its maximum intensity.
# Higher values make the camera react more immediately when damage is received.
@export var damage_feedback_build_speed : float = 0.75

# Speed at which damage feedback returns towards its neutral state.
# Higher values make the camera recover from the damage effect more quickly.
@export var damage_feedback_decay_speed : float = 0.6

# Maximum speed multiplier applied to damage feedback based on damage magnitude.
# Higher values make larger damage reactions build and recover more quickly.
@export var damage_feedback_max_speed_multiplier : float = 4.0
