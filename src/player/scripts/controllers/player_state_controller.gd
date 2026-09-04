class_name PlayerStateController
extends Node

## Coordinates the player's state components.


# Components
@onready var motion : PlayerMotionState = $PlayerMotionState
@onready var lifecycle : PlayerLifecycleState = $PlayerLifecycleState


## Public Interface
# Updates all state components for the current frame.
func update(velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool, crouch_pressed : bool) -> void:
	motion.update(velocity, is_on_floor, can_sprint, sprint_pressed, crouch_pressed)


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


## Public Interface: Lifecycle State
# Returns the player's current lifecycle state.
func get_lifecycle_state() -> PlayerEnums.LifecycleState:
	return lifecycle.get_state()


# Returns whether the player is alive.
func is_alive() -> bool:
	return lifecycle.is_alive()


# Returns whether the player is downed.
func is_downed() -> bool:
	return lifecycle.is_downed()


# Returns whether the player is dead.
func is_dead() -> bool:
	return lifecycle.is_dead()


# Transitions the player into the downed state.
func down() -> void:
	lifecycle.down()


# Transitions the player into the dead state.
func die() -> void:
	lifecycle.die()


# Recovers the player from the downed state.
func recover() -> void:
	lifecycle.recover()


# Resets the player from dead to alive.
func reset() -> void:
	lifecycle.reset()
