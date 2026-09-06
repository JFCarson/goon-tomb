class_name PlayerMovementController
extends EntityController

## Controls the player's movement component using player movement actions.


# Components
@onready var movement : Movement = $Movement
@onready var sprint : Sprint = $Sprint
@onready var jump : Jump = $Jump
@onready var crouch : Crouch = $Crouch

# Runtime
var is_on_floor : bool = true


func _initialise_hook() -> void:
	movement.movement_settings = config.movement
	sprint.movement_settings = config.movement
	jump.movement_settings = config.movement
	crouch.movement_settings = config.movement


## Public Interface
# Calculates the player's resulting velocity from a movement action.
func process_movement(delta : float, current_velocity : Vector3, player_basis : Basis, movement_vector : Vector2, requested_actions : Array[EntityEnums.Action]) -> Vector3:
	var local_direction := Vector3(movement_vector.x, 0.0, movement_vector.y)
	var world_direction : Vector3 = player_basis * local_direction
	
	var speed_multiplier : float = config.movement.walk_multiplier
	
	# Handle requests to sprint.
	var sprinting : bool = false
	if requested_actions.has(EntityEnums.Action.SPRINT) and sprint.can_sprint(movement_vector, is_on_floor):
		speed_multiplier *= sprint.get_speed_multiplier() 
		sprinting = true
	
	# Handle requests to crouch.
	var crouching : bool = false
	if requested_actions.has(EntityEnums.Action.CROUCH):
		speed_multiplier *= crouch.get_speed_multiplier()
		crouching = true
	
	var new_velocity : Vector3 = movement.calculate_velocity(delta, current_velocity, world_direction, movement_vector, speed_multiplier, is_on_floor)
	
	# Preserve the entity's existing vertical velocity.
	new_velocity.y = current_velocity.y
	
	# Handle requests to jump.
	if requested_actions.has(EntityEnums.Action.JUMP) and jump.can_jump(is_on_floor):
		new_velocity.y = jump.calculate_jump_velocity()
	
	# Try to update movement state component if the controller exists.
	if state != null:
		_update_movement_state(new_velocity, sprinting, crouching)
	
	return new_velocity


# Calculates the player's resulting collision height from a crouch action.
func process_crouch(delta : float, current_height : float, standing_height : float, requested_actions : Array[EntityEnums.Action]) -> float:
	var crouching : bool = requested_actions.has(EntityEnums.Action.CROUCH)
	
	return crouch.calculate_height(delta, current_height, standing_height, crouching)


## Private Methods
# Determines and updates the active movement state.
func _update_movement_state(velocity : Vector3, sprinting : bool, crouching : bool) -> void:
	var new_state : EntityStateEnums.Motion
	
	if not is_on_floor:
		new_state = EntityStateEnums.Motion.AIRBORNE
	elif crouching:
		new_state = EntityStateEnums.Motion.CROUCHING
	elif Vector3(velocity.x, 0.0, velocity.z).length_squared() <= 0.01:
		new_state = EntityStateEnums.Motion.IDLE
	elif sprinting:
		new_state = EntityStateEnums.Motion.SPRINTING
	else:
		new_state = EntityStateEnums.Motion.WALKING
	
	if new_state != state.check(EntityStateEnums.States.MOTION):
		state.update(EntityStateEnums.States.MOTION, new_state)
