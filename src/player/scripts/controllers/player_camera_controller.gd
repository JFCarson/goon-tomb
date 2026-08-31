class_name PlayerCameraController
extends Node3D

## Coordinates the player's camera components.


# Components
@onready var camera_arm : CameraArm = $CameraArm


# Handles camera-related input and returns the resulting player yaw.
func handle_input(event : InputEvent) -> float:
	if not event is InputEventMouseMotion:
		return 0.0
	
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return 0.0
	
	return camera_arm.handle_camera_motion(event)


## Public Interface
# Returns the interaction ray used by the camera.
func get_interact_ray() -> RayCast3D:
	return camera_arm.get_interact_ray()


# Updates all camera movement effects for the current frame.
func update(delta : float, player_velocity : Vector3, motion_state : PlayerEnums.MotionState) -> void:
	camera_arm.do_camera_movement_effects(delta, player_velocity, motion_state)


# Triggers camera feedback when the player takes damage.
func damage_feedback(magnitude : float) -> void:
	camera_arm.damage_feedback(magnitude)
