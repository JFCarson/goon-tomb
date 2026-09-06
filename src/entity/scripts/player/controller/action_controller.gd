class_name PlayerActionController
extends EntityController

## Converts player input into gameplay actions.
## The 'create_action_list' method can be used to produce an array of currently
## requested actions, which can then be processed throughout the composition.

## Public Interface
# Declare movement vector based on user input.
func get_move_action() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")


# Returns whether the player is currently requesting to sprint.
func get_sprint_action() -> bool:
	return Input.is_action_pressed("sprint")


# Returns whether the player has requested a jump this frame.
func get_jump_action() -> bool:
	return Input.is_action_just_pressed("jump")


# Returns whether the player is currently requesting to crouch.
func get_crouch_action() -> bool:
	return Input.is_action_pressed("crouch")


# Returns whether the player has requested an interaction this frame.
func get_interact_action() -> bool:
	return Input.is_action_just_pressed("interact")


# Creates an array of active boolean actions for processing on the frame.
func create_action_list() -> Array[EntityEnums.Action]:
	var actions_list : Array[EntityEnums.Action] = []
	
	if get_sprint_action():
		actions_list.append(EntityEnums.Action.SPRINT)
	if get_jump_action():
		actions_list.append(EntityEnums.Action.JUMP)
	if get_crouch_action():
		actions_list.append(EntityEnums.Action.CROUCH)
	if get_interact_action():
		actions_list.append(EntityEnums.Action.INTERACT)
		
	return actions_list
