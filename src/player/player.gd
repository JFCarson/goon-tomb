class_name Player
extends CharacterBody3D

## Orchestrator script for the player.
## Coordinates player components and owns the player's high-level state.


# Controllers
@onready var input : PlayerInputController = $PlayerInputController
@onready var camera : PlayerCameraController = $PlayerCameraController
@onready var resources : PlayerResourceController = $PlayerResourceController
@onready var state : PlayerStateController = $PlayerStateController


# Components
@onready var hud : HUD = $CanvasLayer/HUD


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE
var can_sprint : bool = false


func _process(_delta: float) -> void:
	input.update_interaction()


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input.initialise(camera.get_interact_ray(), hud.get_interact_prompt())


# Fallback handler
func _unhandled_input(event : InputEvent) -> void:
	# Fallback for camera.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(camera.handle_camera_motion(event))
	
	# Fallback for interactions.
	if event.is_action_pressed("interact"):
		input.try_interact()


func _physics_process(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	can_sprint = input.can_sprint(is_on_floor(), resources.can_sprint())
	
	# Determine the player's current motion state.
	state.update(velocity, is_on_floor(), can_sprint, Input.is_action_pressed("sprint"))
	input.set_motion_state(motion_state)
	
	var horizontal_velocity : Vector3 = input.update_movement(delta, velocity, transform.basis, is_on_floor())
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# Handle jumping.
	var jump_velocity : float = input.handle_jump(is_on_floor(), resources.can_jump())

	if jump_velocity > 0.0:
		if resources.consume_jump():
			velocity.y = jump_velocity
	
	move_and_slide()
	
	# Recalculate the state after movement has been resolved.
	motion_state = state.get_motion_state()
	input.set_motion_state(motion_state)
	
	# Update stamina using the resolved movement state.
	resources.update(delta, motion_state)
	
	if motion_state == PlayerEnums.MotionState.SPRINTING and not resources.can_sprint():
		input.lock_sprint()
	
	hud.update_stamina(resources.get_stamina(), resources.get_max_stamina())
	
	# Trigger camera movement effects processing.
	camera.update(delta, velocity, motion_state)
