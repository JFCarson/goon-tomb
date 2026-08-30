class_name PlayerMotionState
extends Node

## Manages the player's current motion state.
## Determines the state from the player's movement and sprint context.


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE


## Public Interface
# Updates the player's current motion state.
func update(velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool) -> void:
	var new_state : PlayerEnums.MotionState
	
	if not is_on_floor:
		new_state = PlayerEnums.MotionState.AIRBORNE
	elif Vector3(velocity.x, 0.0, velocity.z).length_squared() <= 0.01:
		new_state = PlayerEnums.MotionState.IDLE
	elif can_sprint and sprint_pressed:
		new_state = PlayerEnums.MotionState.SPRINTING
	else:
		new_state = PlayerEnums.MotionState.WALKING
	
	if new_state != get_state():
		motion_state = new_state


# Returns the player's current motion state.
func get_state() -> PlayerEnums.MotionState:
	return motion_state


## Internal Calculations
# Determines the appropriate motion state from the player's current conditions.
func _determine_state(velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool) -> PlayerEnums.MotionState:
	if not is_on_floor:
		return PlayerEnums.MotionState.AIRBORNE
	
	if Vector3(velocity.x, 0.0, velocity.z).length_squared() > 0.01:
		if can_sprint and sprint_pressed:
			return PlayerEnums.MotionState.SPRINTING
		
		return PlayerEnums.MotionState.WALKING
	
	return PlayerEnums.MotionState.IDLE
