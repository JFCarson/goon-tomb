class_name PlayerMotionState
extends Node

## Determines the player's current movement state.


# Constants
const MOVEMENT_THRESHOLD : float = 0.01


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE


## Public Interface
# Returns the current movement state.
func get_state() -> PlayerEnums.MotionState:
	return motion_state


# Updates and returns the player's current movement state.
func update(player_velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool) -> PlayerEnums.MotionState:
	motion_state = _determine_state(player_velocity, is_on_floor, can_sprint, sprint_pressed)
	return motion_state


# Determines the player's state from the supplied movement context.
func _determine_state(player_velocity : Vector3, is_on_floor : bool, can_sprint : bool, sprint_pressed : bool) -> PlayerEnums.MotionState:
	if not is_on_floor:
		return PlayerEnums.MotionState.AIRBORNE
	
	var horizontal_velocity : Vector3 = Vector3(player_velocity.x, 0.0, player_velocity.z)
	
	if horizontal_velocity.length_squared() <= MOVEMENT_THRESHOLD:
		return PlayerEnums.MotionState.IDLE
	
	if can_sprint and sprint_pressed:
		return PlayerEnums.MotionState.SPRINTING
	
	return PlayerEnums.MotionState.WALKING
