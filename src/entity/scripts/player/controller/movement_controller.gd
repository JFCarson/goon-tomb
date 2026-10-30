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
	
	for component : EntityComponent in [movement, sprint, jump, crouch]:
		component.initialise(self)


# Public Interface
## Controls all physics movement updates for the player.
func physics_update(delta : float, movement_command : EntityMovementCommand) -> void:
	_process_gravity(delta)
	
	if player.is_alive() and player.can_simulate_movement:
		_process_crouch(delta, movement_command)
		
		if movement_command.jump:
			_process_jump()
			
		_process_velocity(delta, movement_command)
	else:
		player.velocity = Vector3(0.0, player.velocity.y, 0.0)
		
	player.move_and_slide()
	player.resource.process_resources(delta, movement_command)


# Private Methods
## Processes the velocity of the player.
func _process_velocity(delta : float, command : EntityMovementCommand) -> void:
	var movement_vector : Vector2 = command.movement_vector
	var world_direction : Vector3 = player.transform.basis * Vector3(movement_vector.x, 0.0, movement_vector.y)
	
	_update_movement_state(command, movement_vector)
	
	var speed_multiplier : float = player.player_config.movement.walk_multiplier
	
	match entity.state.check(EntityStateEnums.States.MOTION):
		EntityStateEnums.Motion.CROUCHING:
			speed_multiplier *= crouch.get_speed_multiplier()
		EntityStateEnums.Motion.SPRINTING:
			if sprint.can_sprint(movement_vector):
				speed_multiplier *= sprint.get_speed_multiplier()
				
	var new_velocity : Vector3 = movement.calculate_velocity(delta, player.velocity, world_direction, movement_vector, speed_multiplier)
	new_velocity.y = player.velocity.y
	player.velocity = new_velocity


## Processes jumping, whether the player can jump.
func _process_jump() -> void:
	if jump.can_jump():
		player.velocity.y = jump.calculate_jump_velocity()
		player.resource.consume_jump()


## Processes gravity and calculates fall speed.
func _process_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta


## Processes crouching and crouch physics.
func _process_crouch(delta : float, command : EntityMovementCommand) -> void:
	player.collision.shape.height = crouch.calculate_height(delta, player.collision.shape.height, player.standing_height, command.crouch)


## Determines and updates the active movement state.
func _update_movement_state(command : EntityMovementCommand, movement_vector : Vector2) -> void:
	if player.state == null:
		return
		
	var new_state : EntityStateEnums.Motion
	if not player.is_on_floor():
		new_state = EntityStateEnums.Motion.AIRBORNE
		
	elif command.crouch or (entity.state.check(EntityStateEnums.States.MOTION) == EntityStateEnums.Motion.CROUCHING and not crouch.can_stand()):
		new_state = EntityStateEnums.Motion.CROUCHING
		
	elif Vector3(player.velocity.x, 0.0, player.velocity.z).length_squared() <= 0.01:
		new_state = EntityStateEnums.Motion.IDLE
		
	elif command.sprint and sprint.can_sprint(movement_vector):
		new_state = EntityStateEnums.Motion.SPRINTING
		
	else:
		new_state = EntityStateEnums.Motion.WALKING
		
	if new_state != player.state.check(EntityStateEnums.States.MOTION):
		player.state.update(EntityStateEnums.States.MOTION, new_state)
