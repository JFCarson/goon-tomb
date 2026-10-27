class_name PlayerOverlayController
extends PlayerController

## Controller for player HUD & overlay elements.


# Components
## Keeps reference to the player's HUD.
@export var hud : HUD

## Keeps reference to the player's inventory UI.
@export var inventory : PlayerInventoryOverlay


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	# Initialise the HUD with the player's resource values.
	hud.initialise(player.resource, player.damage, player.state)


# Public Interface
## Toggles display for the player's inventory.
func toggle_inventory() -> void:
	inventory.toggle_inventory()
