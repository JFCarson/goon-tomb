class_name PlayerInventoryController
extends PlayerController

## Controller for the player's inventory.


# Runtime
## Runtime data representation of the player's inventory.
@onready var inventory := EntityInventory.new()


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	# Listen for changes to the actual inventory data.
	if not inventory.inventory_updated.is_connected(on_inventory_updated):
		inventory.inventory_updated.connect(on_inventory_updated)
		
	# Listen for item drop requests from the overlay.
	if not player.overlay.inventory.drop_item.is_connected(on_drop_item):
		player.overlay.inventory.drop_item.connect(on_drop_item)


# Public Methods
## Processes the toggling of the player's inventory overlay.
func toggle_inventory() -> void:
	player.overlay.toggle_inventory()
	if player.overlay.inventory.inventory_is_open:
		entity.can_simulate_movement = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		entity.can_simulate_movement = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Listen for changes to the player's inventory.
func on_inventory_updated(inventory_data: Inventory, weight: float, max_weight: float) -> void:
	player.overlay.inventory.update_inventory(inventory_data, weight, max_weight)


## Returns a copy of the current inventory.
func get_inventory() -> Inventory:
	return inventory.get_inventory()


## Force the inventory to signal an update.
func force_update() -> void:
	inventory.force_update()


## Try to add a number of items to the controlled inventory, returning whether
## the operation was a success.
func add_item(item : ItemDefinition, amount : int) -> bool:
	return inventory.add_item(item, amount)


## Try to remove a number of items from the controlled inventory, returning
## whether the operation was a success.
func remove_item(item : ItemDefinition, amount : int) -> bool:
	return inventory.remove_item(item, amount)


## Listen for requests to drop an item.
func on_drop_item(item_definition : ItemDefinition, amount : int) -> void:
	remove_item(item_definition, amount)
	player.camera.drop_item_at_shape_cast(item_definition, amount)
