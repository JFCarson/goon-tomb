class_name Player
extends CharacterBody3D

## Orchestrator script for the player.
## Coordinates player controllers and owns the player's high-level
## CharacterBody3D responsibilities.


# Controllers
@onready var input : PlayerInputController = $PlayerInputController
@onready var camera : PlayerCameraController = $PlayerCameraController
@onready var resources : PlayerResourceController = $PlayerResourceController
@onready var state : PlayerStateController = $PlayerStateController


# Components
@onready var hud : HUD = $CanvasLayer/HUD


# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE


# Updates systems that operate independently of the physics simulation.
func _process(_delta: float) -> void:
	input.update_interaction()


# Initialises the player's input dependencies and captures the mouse.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input.initialise(camera.get_interact_ray(), hud.get_interact_prompt())


# Handle camera movement.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(camera.handle_input(event))


# Updates the player's physical movement and coordinates the player controllers.
func _physics_process(delta : float) -> void:
	# Apply gravity before resolving movement for the current frame.
	_apply_gravity(delta)
	
	# Resolve the current motion state before movement is calculated.
	_update_motion_state()
	
	# Calculate and apply horizontal movement.
	_apply_movement(delta)
	
	# Handle jump input and apply vertical jump velocity when permitted.
	_handle_jump()
	
	# Resolve the player's movement through CharacterBody3D physics.
	move_and_slide()
	
	# Recalculate the motion state using the resolved physics state.
	_update_motion_state()
	
	# Update resource systems and their associated HUD elements.
	_update_resources(delta)
	
	# Apply camera effects using the resolved player movement state.
	_update_camera(delta)


## Private Methods
# Applies gravity while the player is airborne.
func _apply_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# Determines and propagates the player's current motion state.
func _update_motion_state() -> void:
	# Sprinting requires both valid movement conditions and available stamina.
	var can_sprint : bool = input.can_sprint(is_on_floor(), resources.can_sprint())
	
	# Resolve the player's motion state from the current physical and input state.
	state.update(velocity, is_on_floor(), can_sprint, Input.is_action_pressed("sprint"))
	
	# Store the resolved state locally and pass it to movement-dependent components.
	motion_state = state.get_motion_state()
	input.set_motion_state(motion_state)


# Calculates and applies the player's horizontal movement velocity.
func _apply_movement(delta : float) -> void:
	var horizontal_velocity : Vector3 = input.update_movement(delta, velocity, transform.basis, is_on_floor())
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z


# Handles jump input and applies the resulting vertical velocity.
func _handle_jump() -> void:
	var jump_velocity : float = input.handle_jump(is_on_floor(), resources.can_jump())
	
	if jump_velocity > 0.0:
		if resources.consume_jump():
			velocity.y = jump_velocity


# Updates player resources and synchronises the stamina display.
func _update_resources(delta : float) -> void:
	resources.update(delta, motion_state, Input.is_action_pressed("sprint"))
	hud.update_stamina(resources.get_stamina(), resources.get_max_stamina())


# Updates camera movement effects using the player's resolved state and velocity.
func _update_camera(delta : float) -> void:
	camera.update(delta, velocity, motion_state)
