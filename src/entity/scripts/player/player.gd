class_name Player
extends CharacterEntity

## Orchestrator script for the player.


# Configuration
## Provides a type-safe reference to the player config.
var player_config : PlayerConfig:
	get:
		return config as PlayerConfig


# Controllers
## Keeps reference to the player-specific controllers that a Player entity
## must possess as children.
@export_group("Player Controllers")

## Keeps reference to the player's game camera controller component.
@export var camera : GameCameraController

## Keeps reference to the player's action controller component.
@export var action : PlayerActionController

## Keeps reference to the player's interaction controller component.
@export var interaction : PlayerInteractionController

## Keeps reference to the player's movement controller component.
@export var movement : PlayerMovementController

## Keeps reference to the player's inventory controller component.
@export var inventory : PlayerInventoryController

## Keeps reference to the player's overlay controller component.
@export var overlay : PlayerOverlayController


# Runtime
## Stores whether the player is permitted to simulate movement.
var can_simulate_movement : bool = true

## Stores the height of the player's hitbox when in the standing state.
@onready var standing_height : float = collision.shape.height


# Process
## Initialise the entire Player composition when ready.
func _ready() -> void:
	assert(config is PlayerConfig, "Player has been initialised with a standard EntityConfig resource. Needs to be a PlayerConfig resource.")
	
	super._ready()
	
	# Initialise each controller.
	for controller : EntityController in [action, interaction, movement, inventory, overlay]:
		controller.initialise(self)
	
	for controller3d : EntityController3D in [camera]:
		controller3d.initialise(self)
	
	# Initialise the inventory with the starting values by forcing an update
	# signal to be sent.
	inventory.force_update()
	
	# Capture the player's mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Handles isolated player control inputs.
func _input(event : InputEvent) -> void:
	if is_alive():
		if action.get_toggle_inventory_action():
			inventory.toggle_inventory()
		
		if can_simulate_movement:
			if event is InputEventMouseMotion:
				rotate_y(camera.process_look(event.relative))
				
			if action.get_interact_action():
				interaction.try_interact()


## Handles non-physics updates on tick.
func _process(_delta : float) -> void:
	interaction.update_interaction()
	
	var damage_taken : float = damage.process_damage()
	if damage_taken > 0.0:
		camera.cause_damage_feedback(damage_taken / stats.health.base)


## Handles physics updates on tick.
func _physics_process(delta : float) -> void:
	movement.physics_update(delta, action.create_movement_command())
	camera.process_camera_effects(delta, velocity)
	networking.send_movement_state()
