class_name PlayerCrouch
extends Node

## Handles crouch calculations for the player.


# Configuration
@export var crouch_settings : PlayerCrouchSettings


# Runtime State
var collision : CollisionShape3D
var standing_height : float
var target_height : float


func _physics_process(delta : float) -> void:
	if Input.is_action_just_pressed("crouch"):
		target_height = standing_height - crouch_settings.crouch_height_reduction
	elif Input.is_action_just_released("crouch"):
		target_height = standing_height
	
	collision.shape.height = move_toward(collision.shape.height, target_height, crouch_settings.crouch_speed * delta)


## Public Interface
# Initialises the component, populating the collision from the parent.
func initialise(parent_collision : CollisionShape3D) -> void:
	collision = parent_collision
	standing_height = collision.shape.height
	target_height = standing_height
