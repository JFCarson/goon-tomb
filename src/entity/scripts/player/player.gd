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
## Flags whether the player currently can control their character's movement.
var can_control_self : bool = true

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


func _input(event : InputEvent) -> void:
	if action.get_toggle_inventory_action():
		inventory.toggle_inventory()
	
	if can_control_self:
		if event is InputEventMouseMotion:
			var yaw_delta : float = camera.process_look(event.relative)
			rotate_y(yaw_delta)
			
		if action.get_interact_action():
			interaction.try_interact()


func _process(delta : float) -> void:
	camera.process_camera_effects(delta, velocity)
	interaction.update_interaction()
	damage.process_damage()


func _physics_process(delta : float) -> void:
	movement.physics_update(delta, action.create_movement_command())


# Public Interface
## Returns whether the player is alive.
func is_alive() -> bool:
	if not state.is_tracking(EntityStateEnums.States.LIFECYCLE):
		return false
	
	return state.check(EntityStateEnums.States.LIFECYCLE) == EntityStateEnums.Lifecycle.ALIVE


# Private Methods
## Connect signals to listener functions.
func _connect_signals() -> void:
	super._connect_signals()
	interaction.interaction_request.connect(_on_interaction_request)


# Signal Methods
# REFACTOR: CAN BOTH OF THESE METHODS (AND THE ONE ON THE BASE CLASS) BE MADE TO BE PART OF THE CONTROLLERS?
## Listen for requests to pick up an item.
func _on_interaction_request(request : InteractionRequest) -> void:
	if request is PickUpItemRequest:
		if inventory.add_item(request.item, request.amount):
			interaction.finish_interaction(request.ref)


## Listen for requests to process incoming damage.
func _on_damage_taken(amount: float) -> void:
	var max_health: float = resource.get_max_health()
	if max_health <= 0.0:
		return
		
	var magnitude: float = amount / max_health
	camera.cause_damage_feedback(magnitude)
