class_name Player
extends CharacterBody3D

## Orchestrator script for the player.
## Coordinates player components and owns the player's high-level state.


# Components
@onready var camera_manager : CameraManager = $CameraManager
@onready var movement : PlayerMovement = $PlayerMovement
@onready var stamina : PlayerStamina = $PlayerStamina
@onready var hud : HUD = $CanvasLayer/HUD

@export_group("Interact")
@onready var interact_ray: RayCast3D = $CameraManager/Camera/InteractRay
@onready var prompt: Label = $CanvasLayer/HUD/InteractPrompt

# Runtime State
var motion_state : PlayerEnums.MotionState = PlayerEnums.MotionState.IDLE
var can_sprint : bool = false

# Configuration
@export_group("Jump")
@export var jump_height : float


func _ready() -> void:
	# Capture the player's mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	_update_interaction()

# Fallback handler
func _unhandled_input(event : InputEvent) -> void:
	#Fallback for camera
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(camera_manager.handle_camera_motion(event))  # Yaw is returned by handle_camera_motion method.
	#Fallback for interactions
	if event.is_action_pressed("interact"):
		_try_interact()


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
	motion_state = _determine_motion_state()
	movement.set_motion_state(motion_state)
	
	# Calculate and apply horizontal movement.
	var horizontal_velocity : Vector3 = movement.calculate_horizontal_velocity(delta, velocity, direction, input_vector, is_on_floor())
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	# Handle jumping.
	var can_jump : bool = is_on_floor() and stamina.can_afford(stamina.stamina_settings.jump_cost)
	if Input.is_action_just_pressed("jump") and can_jump:
		stamina.consume(stamina.stamina_settings.jump_cost)
		velocity.y = sqrt(2.0 * jump_height)
	
	move_and_slide()
	
	# Recalculate the state after movement has been resolved.
	motion_state = _determine_motion_state()
	movement.set_motion_state(motion_state)
	
	# Update stamina using the resolved movement state.
	stamina.update(delta, motion_state == PlayerEnums.MotionState.SPRINTING)
	hud.update_stamina(stamina.get_stamina(), stamina.get_max_stamina())
	
	# Trigger camera movement effects processing.
	camera_manager.do_camera_movement_effects(delta, velocity, motion_state)


func _determine_motion_state() -> PlayerEnums.MotionState:
	if not is_on_floor():
		return PlayerEnums.MotionState.AIRBORNE
	
	if Vector3(velocity.x, 0.0, velocity.z).length_squared() > 0.01:
		if can_sprint and Input.is_action_pressed("sprint"):
			return PlayerEnums.MotionState.SPRINTING
		return PlayerEnums.MotionState.WALKING
	return PlayerEnums.MotionState.IDLE
	
#This code handles updating the prompt
func _update_interaction() -> void:
	#detects if the raycast is interacting at with an interactable object and returns the Interactable prompt variable within Interactable.gd
	prompt.text = ""
	#early returns if object isn't interactable
	if not interact_ray.is_colliding():
		return
	var collider = interact_ray.get_collider()
	if collider is Interactable:
		#uses the get_prompt funcition in Interactable.gd to get the prompt of the interable object and updates the prompt
		prompt.text = collider.get_prompt()

#This code handles the player pressing interact keybind (default (e))
func _try_interact() -> void:
	#early returns if object isn't interactable
	if not interact_ray.is_colliding():
		return
	var collider = interact_ray.get_collider()
	if collider is Interactable:
		collider.interact()
