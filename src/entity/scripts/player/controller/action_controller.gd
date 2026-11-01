class_name PlayerActionController
extends PlayerController

## Converts player input into gameplay actions.


# Public Interface
## Creates a movement command from the player's current input.
func create_movement_command() -> EntityMovementCommand:
	var command := EntityMovementCommand.new()
	
	command.movement_vector = _get_movement_vector()
	command.sprint = _get_sprint_action()
	command.jump = _get_jump_action()
	command.crouch = _get_crouch_action()
	
	return command


## Returns whether the player has requested an interaction this frame.
func get_interact_action() -> bool:
	return Input.is_action_just_pressed("interact")


## Returns whether the player has requested to toggle their inventory.
func get_toggle_inventory_action() -> bool:
	return Input.is_action_just_pressed("toggle_inventory")


# Private Methods
## Returns the movement vector based on user input.
func _get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")


## Returns whether the player is currently requesting to sprint.
func _get_sprint_action() -> bool:
	return Input.is_action_pressed("sprint")


## Returns whether the player has requested a jump this frame.
func _get_jump_action() -> bool:
	return Input.is_action_just_pressed("jump")


## Returns whether the player is currently requesting to crouch.
func _get_crouch_action() -> bool:
	return Input.is_action_pressed("crouch")
