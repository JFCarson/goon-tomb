class_name Player
extends CharacterBody3D

## Orchestrator script for the player.


# Camera Variables
@export var camera_sensitivity : float
@onready var camera_holder : Node3D = $CameraHolder
var camera_pitch : float = 0.0


func _ready() -> void:
	# Capture the mouse.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Handle horizontal look.
		rotate_y(-event.relative.x * camera_sensitivity)
		
		# Handle vertical look.
		camera_pitch -= event.relative.y * camera_sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-80.0), deg_to_rad(80.0))
		camera_holder.rotation.x = camera_pitch
