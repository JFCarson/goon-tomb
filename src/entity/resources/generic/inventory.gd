class_name Inventory
extends Resource

## Defines the shape of an inventory that can belong to an entity.


# Stores references to each item held in the inventory.
@export var items : Array[InventoryItem] = []

# Stores the current weight of the inventory.
@export var current_weight : float = 0.0

# Defines the maximum weight of the inventory.
@export var max_weight : float = 100.0
