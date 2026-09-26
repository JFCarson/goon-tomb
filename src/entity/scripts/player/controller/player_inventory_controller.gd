class_name PlayerInventoryController
extends EntityController

## Controller for the player's inventory.


## Runtime State
@onready var inventory := EntityInventory.new()


## Public Methods
# Returns a copy of the current inventory.
func get_inventory() -> Array[InventoryItem]:
	return inventory.get_inventory()


# Try to add a number of items to the controlled inventory, returning whether
# the operation was a success.
func add_item(item : ItemDefinition, amount : int) -> bool:
	return inventory.add_item(item, amount)


# Try to remove a number of items from the controlled inventory, returning
# whether the operation was a success.
func remove_item(item : ItemDefinition, amount : int) -> bool:
	return inventory.remove_item(item, amount)
