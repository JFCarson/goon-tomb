class_name PlayerMotionState
extends Node

## Manages the player's current motion state.
## Determines the state from the player's movement and sprint context.


# Runtime State
var motion_state : PlayerEnumsOld.MotionState = PlayerEnumsOld.MotionState.IDLE


## Public Interface
# Updates the player's current motion state.
func update(velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool, crouch_pressed : bool) -> void:
	var new_state : PlayerEnumsOld.MotionState
	
	if not is_on_floor:
		new_state = PlayerEnumsOld.MotionState.AIRBORNE
	elif crouch_pressed:
		new_state = PlayerEnumsOld.MotionState.CROUCHING
	elif Vector3(velocity.x, 0.0, velocity.z).length_squared() <= 0.01:
		new_state = PlayerEnumsOld.MotionState.IDLE
	elif can_sprint and sprint_pressed:
		new_state = PlayerEnumsOld.MotionState.SPRINTING
	else:
		new_state = PlayerEnumsOld.MotionState.WALKING
	
	if new_state != get_state():
		motion_state = new_state
		print(PlayerEnumsOld.MotionState.keys()[motion_state])


# Returns the player's current motion state.
func get_state() -> PlayerEnumsOld.MotionState:
	return motion_state
