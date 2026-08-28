class_name Player
extends CharacterBody3D

## Orchestrator script for the player.
## Coordinates player components and owns the player's high-level state.


# Components
@onready var camera_manager : CameraManager = $CameraManager
@onready var movement : PlayerMovement = $PlayerMovement


# Stores various runtime information about the player character.
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE


@export_group("Jump")
@export var jump_height : float


@export_group("Stamina")
@export var max_stamina : float
@export var stamina_sprint_drain_rate : float
@export var stamina_jump_cost : float
@export var stamina_regeneration_rate : float
@export var stamina_regeneration_delay : float
@onready var stamina : float = max_stamina
var stamina_regeneration_timer : float = 0.0


@export_group("Misc.")
@onready var hud : HUD = $CanvasLayer/HUD


func _ready() -> void:
	# Capture the player's mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Handle camera motion.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(camera_manager.handle_camera_motion(event))


func _physics_process(delta : float) -> void:
	# Apply gravity while airborne.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Read the player's movement input.
	var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	
	# Convert input into a world-space movement direction based on player rotation.
	var direction : Vector3 = (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	
	# Determine whether sprinting is currently available.
	var can_sprint : bool = movement.can_sprint(input_vector, is_on_floor()) and stamina > 0.0
	
	# Update the movement state used by the movement component.
	if can_sprint and Input.is_action_pressed("sprint"):
		motion_state = PlayerEnums.MotionState.SPRINTING
	elif not is_on_floor():
		motion_state = PlayerEnums.MotionState.AIRBORNE
	elif Vector3(velocity.x, 0.0, velocity.z).length_squared() > 0.01:
		motion_state = PlayerEnums.MotionState.WALKING
	else:
		motion_state = PlayerEnums.MotionState.IDLE
	
	movement.set_motion_state(motion_state)
	
	# Calculate and apply horizontal movement.
	var horizontal_velocity : Vector3 = movement.calculate_horizontal_velocity(
		delta,
		velocity,
		direction,
		input_vector,
		is_on_floor()
	)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	# Handle jumping.
	var can_jump : bool = is_on_floor() and stamina >= stamina_jump_cost
	if Input.is_action_just_pressed("jump") and can_jump:
		stamina -= stamina_jump_cost
		stamina_regeneration_timer = stamina_regeneration_delay
		velocity.y = sqrt(2.0 * jump_height)
	
	move_and_slide()
	
	# Recalculate the state after movement has been resolved.
	motion_state = _determine_motion_state()
	movement.set_motion_state(motion_state)
	
	_handle_stamina(delta)
	camera_manager.do_camera_movement_effects(delta, velocity, motion_state)


# Handles Stamina Updates on Delta.
func _handle_stamina(delta : float) -> void:
	if motion_state == PlayerEnums.MotionState.SPRINTING:
		stamina -= stamina_sprint_drain_rate * delta
		stamina_regeneration_timer = stamina_regeneration_delay
		
		if stamina <= 0.0:
			stamina = 0.0
	else:
		if stamina_regeneration_timer > 0.0:
			stamina_regeneration_timer -= delta
		else:
			stamina += stamina_regeneration_rate * delta
			stamina = min(stamina, max_stamina)
	
	hud.update_stamina(stamina, max_stamina)


func _determine_motion_state() -> PlayerEnums.MotionState:
	if not is_on_floor():
		return PlayerEnums.MotionState.AIRBORNE
	
	if Vector3(velocity.x, 0.0, velocity.z).length_squared() > 0.01:
		if movement.motion_state == PlayerEnums.MotionState.SPRINTING:
			return PlayerEnums.MotionState.SPRINTING
		
		return PlayerEnums.MotionState.WALKING
	
	return PlayerEnums.MotionState.IDLE
