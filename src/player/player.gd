class_name Player
extends CharacterBody3D

## Orchestrator script for the player.
## Coordinates player components and owns the player's high-level state.


# Components
@onready var input_controller : PlayerInputController = $PlayerInputController

@onready var camera_arm : CameraArm = $CameraArm
@onready var stamina : PlayerStamina = $PlayerStamina
@onready var motion_state_manager : PlayerMotionState = $PlayerMotionState
@onready var hud : HUD = $CanvasLayer/HUD
@onready var interact_ray: RayCast3D = $CameraArm/Camera/InteractRay
@onready var prompt: Label = $CanvasLayer/HUD/InteractPrompt


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE
var can_sprint : bool = false


func _process(_delta: float) -> void:
	input_controller.update_interaction(interact_ray, prompt)


func _ready() -> void:
	# Capture the player's mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Fallback handler
func _unhandled_input(event : InputEvent) -> void:
	#Fallback for camera
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(camera_arm.handle_camera_motion(event))  # Yaw is returned by handle_camera_motion method.
	#Fallback for interactions
	if event.is_action_pressed("interact"):
		input_controller.try_interact(interact_ray)


func _physics_process(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	can_sprint = input_controller.can_sprint(is_on_floor()) and stamina.can_sprint()
	
	# Determine the player's current motion state.
	motion_state = motion_state_manager.update(velocity, is_on_floor(), can_sprint, Input.is_action_pressed("sprint"))
	input_controller.set_motion_state(motion_state)
	
	var horizontal_velocity : Vector3 = input_controller.update_movement(delta, velocity, transform.basis, is_on_floor())
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	var jump_velocity : float = input_controller.handle_jump(is_on_floor(), stamina.can_jump())

	if jump_velocity > 0.0:
		if stamina.consume_jump():
			velocity.y = jump_velocity
	
	move_and_slide()
	
	# Recalculate the state after movement has been resolved.
	motion_state = motion_state_manager.update(velocity, is_on_floor(), can_sprint, Input.is_action_pressed("sprint"))
	input_controller.set_motion_state(motion_state)
	
	# Update stamina using the resolved movement state.
	stamina.update(delta, motion_state == PlayerEnums.MotionState.SPRINTING)
	hud.update_stamina(stamina.get_stamina(), stamina.get_max_stamina())
	
	# Trigger camera movement effects processing.
	camera_arm.do_camera_movement_effects(delta, velocity, motion_state)
