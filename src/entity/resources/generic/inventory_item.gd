class_name InventoryItem
extends Resource

## Defines the shape of how an item must look when added to an EntityInventory
## class.


# Definition of which item is in the inventory.
@export var definition : ItemDefinition

# How many of the item is in the stack. Defaulted to '1' as not all items are
# stackable.
@export var amount : int = 1
