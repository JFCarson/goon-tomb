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

# Handlers
@onready var damage : PlayerDamageHandler = $PlayerDamageHandler

# Components
@onready var collision : CollisionShape3D = $CollisionShape
var hud : HUD


# Updates systems that operate independently of the physics simulation.
func _process(_delta: float) -> void:
	if not state.is_alive():
		return
	
	input.update_interaction()


# Initialises the player's input dependencies and captures the mouse.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Handle camera movement.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(camera.handle_input(event))


# Updates the player's physical movement and coordinates the player controllers.
func _physics_process(delta : float) -> void:
	# Prevent physics process if player is dead, but keep updating the HUD.
	if not state.is_alive():
	# Continue applying gravity while preventing player-controlled movement.
		_apply_gravity(delta)
		_stop_movement()
		
		# Resolve the player's physical movement.
		move_and_slide()
		
		# Update the HUD.
		_update_hud()
		
		# Apply camera effects using the resolved player movement state.
		_update_camera(delta)
	
		return
	else:
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
		
		# Perform calculations for fall damage.
		damage.update_fall_damage(is_on_floor(), velocity)
		
		# Recalculate the motion state using the resolved physics state.
		_update_motion_state()
		
		# Update resource systems and their associated HUD elements.
		_update_resources(delta)
		
		# Update the HUD.
		_update_hud()
		
		# Apply camera effects using the resolved player movement state.
		_update_camera(delta)


## Public Interface
# Initialises the player.
func initialise(player_hud : HUD) -> void:
	# Initialise the HUD with the player's resource values and current lifecycle state.
	hud = player_hud
	hud.initialise(resources.get_max_health(), resources.get_max_stamina())
	hud.update_lifecycle(state.get_lifecycle_state())
	
	# Initialise the damage handler with the controllers it coordinates.
	damage.initialise(resources, state)
	damage.damage_taken.connect(_on_damage_taken)
	damage.health_restored.connect(_on_health_restored)
	
	# Propagate lifecycle state changes to the HUD.
	state.lifecycle.state_changed.connect(_on_lifecycle_state_changed)
	
	# Initialise player input with the camera interaction ray and HUD prompt.
	input.initialise(collision, camera.get_interact_ray(), hud.get_interact_prompt())



# Resets & respawns the player in its initial gameplay state.
func respawn(spawn_position : Vector3) -> void:
	velocity = Vector3.ZERO
	
	global_position = spawn_position
	
	resources.reset()
	state.reset()
	
	hud.update_health(resources.get_health())
	hud.update_stamina(resources.get_stamina())
	
	input.set_motion_state(PlayerEnums.MotionState.IDLE)


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
	state.update(velocity, is_on_floor(), can_sprint, Input.is_action_pressed("sprint"), Input.is_action_pressed("crouch"))
	
	# Store the resolved state locally and pass it to movement-dependent components.
	input.set_motion_state(state.get_motion_state())


# Calculates and applies the player's horizontal movement velocity.
func _apply_movement(delta : float) -> void:
	var horizontal_velocity : Vector3 = input.update_movement(delta, velocity, transform.basis, is_on_floor())
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z


# Sets player horizontal velocity to 0.0, and set the motion state to idle.
func _stop_movement() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	input.set_motion_state(state.get_motion_state())


# Handles jump input and applies the resulting vertical velocity.
func _handle_jump() -> void:
	var jump_velocity : float = input.handle_jump(is_on_floor(), resources.can_jump())
	
	if jump_velocity > 0.0:
		if resources.consume_jump():
			velocity.y = jump_velocity


# Updates player resources and synchronises the stamina display.
func _update_resources(delta : float) -> void:
	resources.update(delta, state.get_motion_state(), Input.is_action_pressed("sprint"))


# Update the player's HUD with the required values.
func _update_hud() -> void:
	hud.update_health(resources.get_health())
	hud.update_stamina(resources.get_stamina())


# Updates camera movement effects using the player's resolved state and velocity.
func _update_camera(delta : float) -> void:
	camera.update(delta, velocity, state.get_motion_state())


## Signal Methods
# Triggered when damage is taken.
func _on_damage_taken(amount : float) -> void:
	var magnitude : float = amount / resources.get_max_health()
	
	hud.health_feedback(magnitude, HUD.DAMAGE_FEEDBACK_COLOUR)
	camera.damage_feedback(magnitude)


# Triggered when health is restored.
func _on_health_restored(amount : float) -> void:
	var magnitude : float = amount / resources.get_max_health()
	
	hud.health_feedback(magnitude, HUD.HEALING_FEEDBACK_COLOUR)


# Triggered when lifecycle state is changed. 
func _on_lifecycle_state_changed(new_state : PlayerEnums.LifecycleState) -> void:
	hud.update_lifecycle(new_state)
