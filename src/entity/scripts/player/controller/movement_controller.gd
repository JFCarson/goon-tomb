class_name PlayerMovementController
extends PlayerController

## Controls the player's movement component using player movement actions.


# Components
## Keeps reference to the component which handles movement calculations.
@export var movement : Movement

## Keeps reference to the component which handles sprint calculations.
@export var sprint : Sprint

## Keeps reference to the component which handles jump calculations.
@export var jump : Jump

## Keeps reference to the component which handles crouch calculations.
@export var crouch : Crouch


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	movement.movement_settings = player.player_config.movement
	sprint.movement_settings = player.player_config.movement
	jump.movement_settings = player.player_config.movement
	crouch.movement_settings = player.player_config.movement


# Public Interface
## Controls all physics movement updates for the player.
func physics_update (delta: float, action_list: Array[EntityEnums.Action]) -> void:
	process_gravity(delta)
	
	if _is_alive() and player.can_control_self:
		process_velocity(delta, action_list)
		process_jump(action_list)
		process_crouch(delta, action_list)
	else:
		player.velocity.x = 0.0
		player.velocity.z = 0.0
		
	player.move_and_slide()


## Process the velocity of the player.
func process_velocity(delta: float, action_list: Array[EntityEnums.Action]) -> void:
	var movement_action: Vector2 = player.action.get_move_action()
	player.velocity = process_movement_physics(delta, player.velocity, player.transform.basis, movement_action, action_list)


## Processes jumping, whether the player can jump.
func process_jump (action_list: Array[EntityEnums.Action]) -> void:
	if not action_list.has(EntityEnums.Action.JUMP):
		return
		
	if not can_jump():
		return
		
	if not player.resource.can_jump():
		return
		
	player.velocity = process_jump_physics(player.velocity)
	player.resource.consume_jump()


## Processes gravity and calculates fall speed.
func process_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta


## Processes crouching and crouch physics.
func process_crouch(delta: float, action_list: Array[EntityEnums.Action]) -> void:
	player.collision.shape.height = process_crouch_physics(delta, player.collision.shape.height, player.standing_height, action_list)


## Calculates the player's resulting velocity from a movement action.
func process_movement_physics(delta : float, current_velocity : Vector3, player_basis : Basis, movement_vector : Vector2, requested_actions : Array[EntityEnums.Action]) -> Vector3:
	var local_direction := Vector3(movement_vector.x, 0.0, movement_vector.y)
	var world_direction : Vector3 = player_basis * local_direction
	
	var speed_multiplier : float = player.player_config.movement.walk_multiplier
	
	# Handle requests to sprint.
	var sprinting : bool = false
	if requested_actions.has(EntityEnums.Action.SPRINT) and sprint.can_sprint(movement_vector, player.is_on_floor()) and player.resource.can_sprint():
		speed_multiplier *= sprint.get_speed_multiplier()
		sprinting = true
	
	# Handle requests to crouch.
	var crouching : bool = false
	if requested_actions.has(EntityEnums.Action.CROUCH):
		speed_multiplier *= crouch.get_speed_multiplier()
		crouching = true
	
	var new_velocity : Vector3 = movement.calculate_velocity(delta, current_velocity, world_direction, movement_vector, speed_multiplier, player.is_on_floor())
	
	# Preserve the player's existing vertical velocity.
	new_velocity.y = current_velocity.y
	
	# Try to update movement state component if the controller exists.
	if player.state != null:
		_update_movement_state(new_velocity, sprinting, crouching)
	
	return new_velocity


## Calculates the player's resulting vertical velocity from a jump action.
func process_jump_physics(current_velocity : Vector3) -> Vector3:
	var new_velocity : Vector3 = current_velocity
	
	if jump.can_jump(player.is_on_floor()):
		new_velocity.y = jump.calculate_jump_velocity()
	
	return new_velocity


## Returns whether the player can currently perform a jump.
func can_jump() -> bool:
	return jump.can_jump(player.is_on_floor())


## Returns whether the player is currently alive.
func _is_alive() -> bool:
	return player.state.check(EntityStateEnums.States.LIFECYCLE) == EntityStateEnums.Lifecycle.ALIVE


## Calculates the player's resulting collision height from a crouch action.
func process_crouch_physics(delta : float, current_height : float, standing_height : float, requested_actions : Array[EntityEnums.Action]) -> float:
	var crouching : bool = requested_actions.has(EntityEnums.Action.CROUCH)
	
	return crouch.calculate_height(delta, current_height, standing_height, crouching)


# Private Methods
## Determines and updates the active movement state.
func _update_movement_state(velocity : Vector3, sprinting : bool, crouching : bool) -> void:
	var new_state : EntityStateEnums.Motion
	
	if not player.is_on_floor():
		new_state = EntityStateEnums.Motion.AIRBORNE
	elif crouching:
		new_state = EntityStateEnums.Motion.CROUCHING
	elif Vector3(velocity.x, 0.0, velocity.z).length_squared() <= 0.01:
		new_state = EntityStateEnums.Motion.IDLE
	elif sprinting:
		new_state = EntityStateEnums.Motion.SPRINTING
	else:
		new_state = EntityStateEnums.Motion.WALKING
	
	if new_state != player.state.check(EntityStateEnums.States.MOTION):
		player.state.update(EntityStateEnums.States.MOTION, new_state)
