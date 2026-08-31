class_name PlayerResourceController
extends Node

## Coordinates the player's resource components.


# Components
@onready var health : PlayerHealth = $PlayerHealth
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


# Resets all player resources to their configured defaults.
func reset() -> void:
	health.reset()
	stamina.reset()
	sprint_locked = false


## Public Interface: Health
# Returns the player's current health.
func get_health() -> float:
	return health.get_health()


# Returns the player's maximum health.
func get_max_health() -> float:
	return health.get_max_health()


# Returns whether the player is currently alive.
func is_alive() -> bool:
	return health.is_alive()


# Applies damage to the player's health.
func take_damage(amount : float) -> void:
	health.take_damage(amount)


# Restores the player's health.
func heal(amount : float) -> void:
	health.heal(amount)


## Public Interface: Stamina
# Returns the current stamina amount.
func get_stamina() -> float:
	return stamina.get_stamina()


# Returns the maximum stamina amount.
func get_max_stamina() -> float:
	return stamina.get_max_stamina()


# Returns whether the player is currently allowed to sprint.
func can_sprint() -> bool:
	return stamina.can_sprint() and not sprint_locked
	

# Returns whether the player has enough stamina to jump.
func can_jump() -> bool:
	return stamina.can_jump()


# Consumes the stamina cost of jumping.
func consume_jump() -> bool:
	return stamina.consume_jump()
