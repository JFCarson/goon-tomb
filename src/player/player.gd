class_name Player
extends CharacterBody3D

## Orchestrator script for the player.
## Coordinates player components and owns the player's high-level state.


# Components
@onready var camera_manager : CameraManager = $CameraManager
@onready var movement : PlayerMovement = $PlayerMovement
@onready var jump : PlayerJump = $PlayerJump
@onready var stamina : PlayerStamina = $PlayerStamina
@onready var interactions : PlayerInteractions = $PlayerInteractions
@onready var motion_state_manager : PlayerMotionState = $PlayerMotionState
@onready var hud : HUD = $CanvasLayer/HUD
@onready var interact_ray: RayCast3D = $CameraManager/Camera/InteractRay
@onready var prompt: Label = $CanvasLayer/HUD/InteractPrompt


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE
var can_sprint : bool = false


func _process(_delta: float) -> void:
	interactions._update_interaction(interact_ray, prompt)

func _ready() -> void:
	# Capture the player's mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Fallback handler
func _unhandled_input(event : InputEvent) -> void:
	#Fallback for camera
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(camera_manager.handle_camera_motion(event))  # Yaw is returned by handle_camera_motion method.
	#Fallback for interactions
	if event.is_action_pressed("interact"):
		interactions._try_interact(interact_ray)


func _physics_process(delta : float) -> void:
	# Apply gravity while airborne.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Read the player's movement input.
	var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	
	# Convert input into a world-space movement direction based on player rotation.
	var direction : Vector3 = (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	
	# Determine whether the current input is eligible for sprinting.
	can_sprint = movement.can_sprint(input_vector, is_on_floor()) and stamina.can_sprint()
	
	# Determine the movement state used by the movement component.
	motion_state = motion_state_manager.update(velocity, is_on_floor(), can_sprint, Input.is_action_pressed("sprint"))
	movement.set_motion_state(motion_state)
	
	# Calculate and apply horizontal movement.
	var horizontal_velocity : Vector3 = movement.calculate_horizontal_velocity(delta, velocity, direction, input_vector, is_on_floor())
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	# Handle jumping.
	if Input.is_action_just_pressed("jump") and jump.can_jump(is_on_floor()) and stamina.can_jump():
		if stamina.consume_jump():
			velocity.y = jump.calculate_jump_velocity()
	
	move_and_slide()
	
	# Recalculate the state after movement has been resolved.
	motion_state = motion_state_manager.update(velocity, is_on_floor(), can_sprint, Input.is_action_pressed("sprint"))
	movement.set_motion_state(motion_state)
	
	# Update stamina using the resolved movement state.
	stamina.update(delta, motion_state == PlayerEnums.MotionState.SPRINTING)
	hud.update_stamina(stamina.get_stamina(), stamina.get_max_stamina())
	
	# Trigger camera movement effects processing.
	camera_manager.do_camera_movement_effects(delta, velocity, motion_state)
