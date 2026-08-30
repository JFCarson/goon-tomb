class_name PlayerResourceController
extends Node

## Coordinates the player's resource components.


# Components
@onready var stamina : PlayerStamina = $PlayerStamina


# Runtime State
var sprint_locked : bool = false


## Public Interface
# Updates all resource components for the current frame.
func update(delta : float, motion_state : PlayerEnums.MotionState, sprint_pressed : bool) -> void:
	stamina.update(delta, motion_state == PlayerEnums.MotionState.SPRINTING)
	
	if not sprint_pressed:
		sprint_locked = false
	if motion_state == PlayerEnums.MotionState.SPRINTING and not stamina.can_sprint():
		sprint_locked = true


# Returns whether the player is currently allowed to sprint.
func can_sprint() -> bool:
	return stamina.can_sprint() and not sprint_locked


## Public Interface: Stamina
# Returns the current stamina amount.
func get_stamina() -> float:
	return stamina.get_stamina()


# Returns the maximum stamina amount.
func get_max_stamina() -> float:
	return stamina.get_max_stamina()


# Returns whether the player has enough stamina to jump.
func can_jump() -> bool:
	return stamina.can_jump()


# Consumes the stamina cost of jumping.
func consume_jump() -> bool:
	return stamina.consume_jump()
