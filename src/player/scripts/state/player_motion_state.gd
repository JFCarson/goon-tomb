class_name PlayerMotionState
extends Node

## Manages the player's current motion state.
## Determines the state from the player's movement and sprint context.


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE


## Public Interface
# Updates the player's current motion state.
func update(velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool, crouch_pressed : bool) -> void:
	var new_state : PlayerEnums.MotionState
	
	if not is_on_floor:
		new_state = PlayerEnums.MotionState.AIRBORNE
	elif crouch_pressed:
		new_state = PlayerEnums.MotionState.CROUCHING
	elif Vector3(velocity.x, 0.0, velocity.z).length_squared() <= 0.01:
		new_state = PlayerEnums.MotionState.IDLE
	elif can_sprint and sprint_pressed:
		new_state = PlayerEnums.MotionState.SPRINTING
	else:
		new_state = PlayerEnums.MotionState.WALKING
	
	if new_state != get_state():
		motion_state = new_state
		print(PlayerEnums.MotionState.keys()[motion_state])


# Returns the player's current motion state.
func get_state() -> PlayerEnums.MotionState:
	return motion_state
