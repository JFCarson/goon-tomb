class_name PlayerResourceController
extends Node

## Coordinates the player's resource components.
## Provides a single interface for the player orchestrator to
## interact with resources such as stamina and health.


# Components
@onready var stamina : PlayerStamina = $PlayerStamina


## Public Interface
# Updates all resource components for the current frame.
func update(delta : float, motion_state : PlayerEnums.MotionState) -> void:
	stamina.update(delta, motion_state == PlayerEnums.MotionState.SPRINTING)


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


# Returns whether the player has enough stamina to sprint.
func can_sprint() -> bool:
	return stamina.can_sprint()
