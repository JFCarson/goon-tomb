class_name CameraLook
extends Node

## Performs calculations for camera look input.


# Config
var camera_config : GameCameraConfig


# Runtime
var _pitch: float = 0.0


## Public Interface
# Processes look input and returns the resulting camera rotation.
func look(input_delta: Vector2) -> Vector2:
	var yaw_delta: float = -input_delta.x * camera_config.sensitivity

	_pitch -= input_delta.y * camera_config.sensitivity
	_pitch = clamp(_pitch, -camera_config.radius, camera_config.radius)

	return Vector2(yaw_delta, _pitch)


# Returns the current vertical camera angle in radians.
func get_pitch() -> float:
	return _pitch


# Resets the camera to its neutral vertical orientation.
func reset() -> void:
	_pitch = 0.0
