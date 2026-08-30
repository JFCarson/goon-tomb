class_name PlayerInputController
extends Node

## Coordinates player input-driven components.


# Components
@onready var movement : PlayerMovement = $PlayerMovement
@onready var jump : PlayerJump = $PlayerJump
@onready var interactions : PlayerInteractions = $PlayerInteractions


## Public Interface
# Returns the current movement input.
func get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")


# Calculates the player's horizontal movement.
func update_movement(delta : float, current_velocity : Vector3, player_basis : Basis, is_on_floor : bool) -> Vector3:
	var input_vector : Vector2 = get_input_vector()
	
	var direction : Vector3 = (player_basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	
	return movement.calculate_horizontal_velocity(delta, current_velocity, direction, input_vector, is_on_floor)


# Determines whether sprinting is available.
func can_sprint(is_on_floor : bool) -> bool:
	return movement.can_sprint(get_input_vector(), is_on_floor)


# Handles jump input and returns a jump velocity.
# Returns 0.0 if no jump should occur.
func handle_jump(is_on_floor : bool, can_afford_jump : bool) -> float:
	if not Input.is_action_just_pressed("jump"):
		return 0.0
	
	if not jump.can_jump(is_on_floor):
		return 0.0
	
	if not can_afford_jump:
		return 0.0
	
	return jump.calculate_jump_velocity()


# Updates interaction prompts.
func update_interaction(interact_ray : RayCast3D, prompt : Label) -> void:
	interactions.update_interaction(interact_ray, prompt)


# Attempts interaction.
func try_interact(interact_ray : RayCast3D) -> void:
	interactions.try_interact(interact_ray)


# Passes motion state through to movement.
func set_motion_state(state : PlayerEnums.MotionState) -> void:
	movement.set_motion_state(state)
