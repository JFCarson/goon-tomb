class_name PlayerInputController
extends Node

## Coordinates player input-driven components.


# Components
@onready var movement : PlayerMovement = $PlayerMovement
@onready var jump : PlayerJump = $PlayerJump
@onready var crouch : PlayerCrouch = $PlayerCrouch
@onready var interaction : PlayerInteraction = $PlayerInteraction


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE
var sprint_locked : bool = false


## Public Interface
# Initialises input-driven components with their required references.
func initialise(collision : CollisionShape3D, interact_ray : RayCast3D, prompt : Label) -> void:
	crouch.initialise(collision)
	interaction.initialise(interact_ray, prompt)


# Returns the current movement input.
func get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")


# Calculates the player's horizontal movement.
func update_movement(delta : float, current_velocity : Vector3, player_basis : Basis, is_on_floor : bool) -> Vector3:
	var input_vector : Vector2 = get_input_vector()
	var direction : Vector3 = (player_basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	return movement.calculate_horizontal_velocity(delta, current_velocity, direction, input_vector, is_on_floor)


# Determines whether sprinting is available.
func can_sprint(is_on_floor : bool, has_stamina : bool) -> bool:
	if not Input.is_action_pressed("sprint"):
		sprint_locked = false
		return false
	
	if sprint_locked:
		return false
	
	if not movement.can_sprint(get_input_vector(), is_on_floor):
		return false
	
	return has_stamina


# Locks sprinting until the sprint key is released.
func lock_sprint() -> void:
	sprint_locked = true


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


# Passes the current motion state through to movement.
func set_motion_state(state : PlayerEnums.MotionState) -> void:
	motion_state = state
	movement.set_motion_state(state)


# Updates the interaction prompt and handles interaction input.
func update_interaction() -> void:
	interaction.update_interaction()
	
	if Input.is_action_just_pressed("interact"):
		interaction.try_interact()
