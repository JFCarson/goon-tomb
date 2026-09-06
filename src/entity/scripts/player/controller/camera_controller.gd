class_name GameCameraController
extends EntityController3D

## Controller for all components of the player's game camera.


# Components
@onready var camera : Camera3D = $PlayerCameraHead/Camera3D
@onready var camera_head : Node3D = $PlayerCameraHead
@onready var camera_look : CameraLook = $PlayerCameraHead/CameraLook
@onready var camera_bob : CameraBob = $CameraBob
@onready var camera_sway : CameraSway = $CameraSway


func _initialise_hook() -> void:
	camera_look.camera_config = config.camera
	
	camera_bob.config = config
	camera_bob.state = state
	
	camera_sway.config = config

# Runtime
@onready var camera_default_position : Vector3 = camera.position


## Process
func process_look(input_delta: Vector2) -> float:
	var look_rotation: Vector2 = camera_look.look(input_delta)
	camera_head.rotation.x = look_rotation.y
	
	return look_rotation.x


# Processes camera effects for the current frame.
func process_camera_effects(delta : float, player_velocity : Vector3) -> void:
	_process_bob(delta, player_velocity)
	_process_sway(delta, player_velocity)


## Public Interface
# Gets reference to the InteractRay attached to the camera.
func get_interact_ray() -> RayCast3D:
	return $PlayerCameraHead/Camera3D/InteractRay


## Private Methods
# Processes the camera bob effect.
func _process_bob(delta : float, player_velocity : Vector3) -> void:
	camera.position = camera_default_position + camera_bob.calculate(delta, player_velocity)


# Processes the camera sway effect.
func _process_sway(delta : float, player_velocity : Vector3) -> void:
	var sway_rotation : Vector3 = camera_sway.calculate(delta, player_velocity, camera.global_transform.basis)
	
	camera.rotation.x = sway_rotation.x
	camera.rotation.z = sway_rotation.z


## Validation
func _validate() -> void:
	assert(camera_head != null, "The GameCameraController requires a PlayerCameraHead Node3D as a direct child.")
	assert(camera_look != null, "The GameCameraController requires a CameraLook component under PlayerCameraHead.")
