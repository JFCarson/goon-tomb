class_name GameCameraController
extends EntityController3D

## Controller for all components of the player's game camera.


## Components
@onready var camera : Camera3D = $PlayerCameraHead/Camera3D
@onready var camera_head : Node3D = $PlayerCameraHead
@onready var interact_ray : RayCast3D = $PlayerCameraHead/Camera3D/InteractRay
@onready var camera_look : CameraLook = $PlayerCameraHead/CameraLook
@onready var camera_bob : CameraBob = $CameraBob
@onready var camera_sway : CameraSway = $CameraSway
@onready var damage_feedback : CameraDamageFeedback = $CameraDamageFeedback


## Runtime State
@onready var camera_default_position : Vector3 = camera.position


func _initialise_hook() -> void:
	camera_look.camera_config = config.camera
	
	camera_bob.config = config
	camera_bob.state = state
	
	camera_sway.config = config
	
	damage_feedback.config = config


## Public Interface
# Processes camera look input and returns the resulting yaw rotation.
func process_look(input_delta : Vector2) -> float:
	var look_rotation : Vector2 = camera_look.look(input_delta)
	camera_head.rotation.x = look_rotation.y
	
	return look_rotation.x


# Processes camera effects for the current frame.
func process_camera_effects(delta : float, player_velocity : Vector3) -> void:
	_process_bob(delta, player_velocity)
	_process_sway(delta, player_velocity)


# Gets reference to the InteractRay attached to the camera.
func get_interact_ray() -> RayCast3D:
	return interact_ray


# Triggers camera feedback when the player takes damage.
func cause_damage_feedback(magnitude : float) -> void:
	damage_feedback.feedback(magnitude)


## Private Methods
# Processes the camera bob effect.
func _process_bob(delta : float, player_velocity : Vector3) -> void:
	camera.position = camera_default_position + camera_bob.calculate(delta, player_velocity)


# Processes the camera sway and damage feedback effects.
func _process_sway(delta : float, player_velocity : Vector3) -> void:
	var sway_rotation : Vector3 = camera_sway.calculate(delta, player_velocity, camera.global_transform.basis)
	var damage_rotation : float = damage_feedback.update(delta)
	
	camera.rotation.x = sway_rotation.x + damage_rotation
	camera.rotation.z = sway_rotation.z


## Validation
func validate() -> void:
	assert(camera != null, "GameCameraController requires a Camera3D component.")
	assert(camera_head != null, "GameCameraController requires a PlayerCameraHead Node3D.")
	assert(interact_ray != null, "GameCameraController requires an InteractRay RayCast3D.")
	assert(camera_look != null, "GameCameraController requires a CameraLook component.")
	assert(camera_bob != null, "GameCameraController requires a CameraBob component.")
	assert(camera_sway != null, "GameCameraController requires a CameraSway component.")
	assert(damage_feedback != null, "GameCameraController requires a CameraDamageFeedback component.")
	assert(config.camera != null, "GameCameraController requires a PlayerCameraConfig.")
	assert(state != null, "GameCameraController requires an EntityStateController.")
	
	camera_look.validate()
	camera_bob.validate()
	camera_sway.validate()
	damage_feedback.validate()
