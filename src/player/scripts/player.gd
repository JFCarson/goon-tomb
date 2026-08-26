class_name Player
extends CharacterBody3D

## Orchestrator script for the player.


# Camera Variables
@export var camera_sensitivity : float
@onready var camera_holder : Node3D = $CameraHolder
var camera_pitch : float = 0.0

# Movement Variables
@export var movement_speed : float

# Gravitational Values
@export var gravity : float


func _ready() -> void:
	# Capture the mouse.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Handle looking with mouse motion.
	if event is InputEventMouseMotion:
		# Handle horizontal look.
		rotate_y(-event.relative.x * camera_sensitivity)
		
		# Handle vertical look.
		camera_pitch -= event.relative.y * camera_sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
		camera_holder.rotation.x = camera_pitch


func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction := transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)
	
	direction = direction.normalized()

	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
