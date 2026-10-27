class_name GameCameraController
extends PlayerController3D

## Controller for all components of the player's game camera.


# Components
## Keeps reference to the player's game camera.
@export var camera : Camera3D

## Keeps reference to the pivot that the camera is attached to.
@export var camera_head : Node3D

## Keeps reference to the interact ray.
@export var interact_ray : RayCast3D

## Keeps reference to the shape cast that is used to determine the location in
## which the player drops items.
@export var drop_shape_cast : ShapeCast3D

## Keeps reference to the component that handles look calculations.
@export var camera_look : CameraLook

## Keeps reference to the component that handles camera bob calculations.
@export var camera_bob : CameraBob

## Keeps reference to the component that handles camera sway calculations.
@export var camera_sway : CameraSway

## Keeps reference to the component that handles damage feedback motion
## calculations.
@export var damage_feedback : CameraDamageFeedback


# Runtime
## Keeps reference to the camera's resting position relative to the player.
@onready var camera_default_position : Vector3 = camera.position


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	# REFACTOR: THIS IS MESSY
	camera_look.camera_config = player.player_config.camera
	
	camera_bob.config = player.player_config
	camera_bob.state = player.state
	
	camera_sway.config = player.player_config
	
	damage_feedback.config = player.player_config


# Public Interface
## Processes camera look input and returns the resulting yaw rotation.
func process_look(input_delta : Vector2) -> float:
	var look_rotation : Vector2 = camera_look.look(input_delta)
	camera_head.rotation.x = look_rotation.y
	
	return look_rotation.x


## Processes camera effects for the current frame.
func process_camera_effects(delta : float, player_velocity : Vector3) -> void:
	_process_bob(delta, player_velocity)
	_process_sway(delta, player_velocity)


## Gets reference to the InteractRay attached to the camera.
func get_interact_ray() -> RayCast3D:
	return interact_ray


## Triggers camera feedback when the player takes damage.
func cause_damage_feedback(magnitude : float) -> void:
	damage_feedback.feedback(magnitude)


## Processes a request to drop an item in the world, removing it from the
## inventory and creating a WorldItem at the DropShapeCast.
func drop_item_at_shape_cast(item : ItemDefinition, amount : int) -> void:
	var item_instance : WorldItem = CreateWorldItem.create_item_instance(item, amount)
	item_instance.visible = false
	
	get_tree().current_scene.add_child(item_instance)
	
	var target_position : Vector3 = _calculate_drop_position(item_instance.collision.shape)
	item_instance.position = target_position
	item_instance.visible = true


# Private Methods
## Processes the camera bob effect.
func _process_bob(delta : float, player_velocity : Vector3) -> void:
	camera.position = camera_default_position + camera_bob.calculate(delta, player_velocity)


## Processes the camera sway and damage feedback effects.
func _process_sway(delta : float, player_velocity : Vector3) -> void:
	var sway_rotation : Vector3 = camera_sway.calculate(delta, player_velocity, camera.global_transform.basis)
	var damage_rotation : float = damage_feedback.update(delta)
	
	camera.rotation.x = sway_rotation.x + damage_rotation
	camera.rotation.z = sway_rotation.z


## Calculate the world position of where an item should be dropped.
func _calculate_drop_position(collision : Shape3D) -> Vector3:
	drop_shape_cast.shape = collision
	drop_shape_cast.force_shapecast_update()
	
	if drop_shape_cast.is_colliding():
		return drop_shape_cast.get_collision_point(0)
	else:
		return drop_shape_cast.to_global(drop_shape_cast.target_position)
