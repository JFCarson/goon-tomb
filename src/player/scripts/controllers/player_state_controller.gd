class_name PlayerStateController
extends Node

## Coordinates the player's state components.


# Components
@onready var motion : PlayerMotionState = $PlayerMotionState


## Public Interface
# Updates all state components for the current frame.
func update(velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool) -> void:
	motion.update(velocity, is_on_floor, can_sprint, sprint_pressed)


## Public Interface: Motion State
# Returns the player's current motion state.
func get_motion_state() -> PlayerEnums.MotionState:
	return motion.get_state()


# Returns whether the player is currently sprinting.
func is_sprinting() -> bool:
	return motion.is_sprinting()


# Returns whether the player is currently airborne.
func is_airborne() -> bool:
	return motion.is_airborne()
