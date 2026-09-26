class_name EntityInventory
extends Node

## Base implementation for an inventory which can store items defined with the
## ItemDefinition resource.


## Config
# Defines how much weight can be stored in a container.
var weight_capacity : float = 100.0


## Runtime State
# Stores the contents of the inventory.
var inventory : Array[InventoryItem] = []

# Stores the current weight of the inventory.
var weight : float = 0.0


## Signals
# Triggered when inventory changes.
signal inventory_updated(inventory : Array[InventoryItem], weight : float, max_weight : float)


## Process
func _init() -> void:
	_validate()


## Public Interface
# Returns a copy of the current inventory array.
func get_inventory() -> Array[InventoryItem]:
	return inventory.duplicate()


# Adds an item to the inventory, and returns if the operation was a success.
func add_item(item : ItemDefinition, amount : int) -> bool:
	if amount <= 0:
		return false
	
	if (item.weight * amount) + weight > weight_capacity:
		return false
	
	if item.can_stack and check_for(item):
		inventory[_get_index_of(item)].amount += amount
	else:
		if item.can_stack:
			_create_new_item(item, amount)
		else:
			for n : int in range(amount):
				_create_new_item(item)
	
	_signal_inventory_change()
	
	return true


# Removes an item from the inventory, and returns if the operation was a success.
func remove_item(item : ItemDefinition, amount : int) -> bool:
	if amount > get_item_count(item) or amount <= 0:
		return false
		
	if item.can_stack:
		var index : int = _get_index_of(item)
		inventory[index].amount -= amount
		
		if inventory[index].amount <= 0:
			inventory.remove_at(index)
	else:
		for i : int in range(amount):
			inventory.remove_at(_get_index_of(item))
	
	_signal_inventory_change()
	
	return true


# Checks if a particular item is in the inventory, and returns whether or not
# it exists in the inventory.
func check_for(item : ItemDefinition) -> bool:
	return _get_index_of(item) != -1


# Returns the number of a particular item contained in the inventory.
func get_item_count(item : ItemDefinition) -> int:
	var index : int = _get_index_of(item)

	if index == -1:
		return 0
	
	if item.can_stack:
		return inventory[index].amount
	
	var count : int = 0
	
	for inventory_item : InventoryItem in inventory:
		if inventory_item.definition == item:
			count += 1
	
	return count


## Private Methods
# Creates a resource for a new item. By default, the amount of item(s) is 1.
func _create_new_item(item : ItemDefinition, amount : int = 1) -> void:
	var new_item := InventoryItem.new()
	new_item.definition = item
	new_item.amount = amount
	
	inventory.append(new_item)


# Returns the index of an item in the inventory array, returning -1 if not found.
func _get_index_of(item : ItemDefinition) -> int:
	for index : int in inventory.size():
		if inventory[index].definition == item:
			return index
	
	return -1


# Signals that the inventory has been changed somehow.
func _signal_inventory_change() -> void:
	weight = _calculate_weight()
	inventory_updated.emit(get_inventory(), weight, weight_capacity)


# Calculates current inventory weight.
func _calculate_weight() -> float:
	var new_weight : float = 0.0
	
	for i : InventoryItem in inventory:
		new_weight += i.definition.weight * i.amount
	
	return new_weight


## Validation
func _validate() -> void:
	assert(
		weight_capacity >= 0.0,
		"Inventory '%s' has an invalid weight capacity of '%s'. Value must be 0.0 or greater."
		% [self, weight_capacity]
	)
