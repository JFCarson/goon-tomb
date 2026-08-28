class_name Player
extends CharacterBody3D

## Orchestrator script for the player.


@export_group("Camera")
@export var camera_sensitivity : float
@export var headbob_frequency : float
@export var headbob_amplitude : float
@export var headbob_sprint_frequency_multiplier : float
@onready var camera : Camera3D = $CameraHolder/Camera
@onready var camera_holder : Node3D = $CameraHolder
@onready var camera_holder_default_position : Vector3 = camera_holder.position
var camera_pitch : float = 0.0
var headbob_time : float = 0.0
var current_headbob_frequency_multiplier : float = 1.0

@export_group("Movement")
@export var movement_speed : float
@export var acceleration : float
@export var turn_acceleration : float
@export var sprint_multiplier : float
@export var backward_speed_multiplier : float
@export var air_movement_speed_percentage : float
@export var jump_height : float
var is_sprinting : bool = false
var is_sprint_locked : bool = false

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


func _unhandled_input(event : InputEvent) -> void:
	# Handle camera inputs.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * camera_sensitivity)

		camera_pitch -= event.relative.y * camera_sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
		camera_holder.rotation.x = camera_pitch


func _physics_process(delta : float) -> void:
	# Apply gravity while airborne.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Read the player's movement input.
	var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	
	# Convert input into a world-space movement direction based on player rotation.
	var direction : Vector3 = (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	
	# Interpolate how forward or backward the player is moving.
	var forwardness : float = (-input_vector.y + 1.0) / 2.0
	
	# Update the player's sprint state.
	var can_sprint : bool = forwardness > 0.5 and not input_vector.is_zero_approx() and stamina > 0.0 and not is_sprint_locked and is_on_floor()
	is_sprinting = Input.is_action_pressed("sprint") and can_sprint
	
	# Remove sprint lock once sprint input is no longer pressed.
	if not Input.is_action_pressed("sprint") and stamina != 0:
		is_sprint_locked = false
	
	# Calculate speed multipliers.
	var speed_multiplier : float = lerp(backward_speed_multiplier, 1.0, forwardness)
	if is_sprinting:
		speed_multiplier = sprint_multiplier
	
	# Calculate the final movement speed and control state.
	var speed : float = movement_speed * speed_multiplier
	var control : float = 1.0 if is_on_floor() else air_movement_speed_percentage
	
	# Handle acceleration/deceleration.
	if direction:
		var target_velocity : Vector3 = direction * speed
		var horizontal_velocity : Vector3 = Vector3(velocity.x, 0.0, velocity.z)
		var acceleration_rate : float = acceleration
		
		if is_on_floor():
			if horizontal_velocity.dot(target_velocity) < 0.0:
				acceleration_rate = turn_acceleration
			
			if horizontal_velocity.length_squared() < 0.01:
				horizontal_velocity = target_velocity
			else:
				horizontal_velocity = horizontal_velocity.move_toward(
					target_velocity,
					acceleration_rate * delta
				)
		else:
			horizontal_velocity = horizontal_velocity.move_toward(
				direction * horizontal_velocity.length(),
				acceleration * control * delta
			)
		
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * control * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * control * delta)
		
	# Handle jumping.
	var can_jump : bool = is_on_floor() and stamina >= stamina_jump_cost
	if Input.is_action_just_pressed("jump") and can_jump:
		stamina -= stamina_jump_cost
		stamina_regeneration_timer = stamina_regeneration_delay
		velocity.y = sqrt(2.0 * jump_height)
	
	move_and_slide()
	_handle_stamina(delta)
	_headbob(delta)


# Handles Headbob.
func _headbob(delta : float) -> void:
	var headbob_position : Vector3 = Vector3.ZERO
	var frequency_multiplier : float = headbob_sprint_frequency_multiplier if is_sprinting else 1.0
	
	headbob_time += delta * velocity.length() * frequency_multiplier * float(is_on_floor())
	
	headbob_position.x = cos(headbob_time * headbob_frequency / 2) * headbob_amplitude
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	
	camera.transform.origin = headbob_position
	

# Handles Stamina Updates on Delta.
func _handle_stamina(delta : float) -> void:
	if is_sprinting:
		stamina -= stamina_sprint_drain_rate * delta
		stamina_regeneration_timer = stamina_regeneration_delay
		
		if stamina <= 0.0:
			stamina = 0.0
			is_sprinting = false
			is_sprint_locked = true
	else:
		if stamina_regeneration_timer > 0.0:
			stamina_regeneration_timer -= delta
		else:
			stamina += stamina_regeneration_rate * delta
			stamina = min(stamina, max_stamina)
			
	hud.update_stamina(stamina, max_stamina)
