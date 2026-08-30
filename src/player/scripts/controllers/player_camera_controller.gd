class_name PlayerCameraController
extends Node3D

## Coordinates the player's camera components.


# Components
@onready var camera_arm : CameraArm = $CameraArm


## Public Interface
# Handles mouse input and returns the yaw rotation for the player.
func handle_camera_motion(event : InputEvent) -> float:
	return camera_arm.handle_camera_motion(event)


# Returns the interaction ray used by the camera.
func get_interact_ray() -> RayCast3D:
	return camera_arm.get_interact_ray()


# Updates all camera movement effects for the current frame.
func update(delta : float, player_velocity : Vector3, motion_state : PlayerEnums.MotionState) -> void:
	camera_arm.do_camera_movement_effects(delta, player_velocity, motion_state)
