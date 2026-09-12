class_name CameraLook
extends Node

## Performs calculations for camera look input.


## Configuration
var camera_config : GameCameraConfig


## Runtime State
var _pitch : float = 0.0


## Public Interface
# Processes look input and returns the resulting camera rotation.
func look(input_delta : Vector2) -> Vector2:
	var yaw_delta : float = -input_delta.x * camera_config.sensitivity
	
	_pitch -= input_delta.y * camera_config.sensitivity
	_pitch = clamp(_pitch, -deg_to_rad(camera_config.pitch_limit), deg_to_rad(camera_config.pitch_limit))
	
	return Vector2(yaw_delta, _pitch)


# Returns the current vertical camera angle in radians.
func get_pitch() -> float:
	return _pitch


# Resets the camera to its neutral vertical orientation.
func reset() -> void:
	_pitch = 0.0


## Validation
func _validate() -> void:
	assert(camera_config != null, "CameraLook requires a GameCameraConfig.")
	assert(camera_config.sensitivity >= 0.0, "CameraLook requires sensitivity to be zero or greater.")
	assert(camera_config.pitch_limit >= 0.0, "CameraLook requires pitch_limit to be zero or greater.")
	assert(camera_config.pitch_limit <= 90.0, "CameraLook requires pitch_limit to be 90 degrees or less.")
