class_name EntityInventory
extends Node

## Base implementation for an inventory which can store items defined with the
## ItemDefinition resource.


## Runtime State
# Stores reference to the inventory object.
var inventory : Inventory


## Signals
# Triggered when inventory changes.
signal inventory_updated(inventory : Inventory, weight : float, max_weight : float)


## Process
# Create the inventory on init, and validate.
func _init() -> void:
	inventory = Inventory.new()
	_validate()


## Public Interface
# Returns a copy of the current inventory array.
func get_inventory() -> Inventory:
	return inventory.duplicate()


# Adds an item to the inventory, and returns if the operation was a success.
func add_item(item : ItemDefinition, amount : int) -> bool:
	if amount <= 0:
		return false
	
	if (item.weight * amount) + inventory.current_weight > inventory.max_weight:
		return false
	
	if item.can_stack and check_for(item):
		inventory.items[_get_index_of(item)].amount += amount
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
		inventory.items[index].amount -= amount
		
		if inventory.items[index].amount <= 0:
			inventory.items.remove_at(index)
	else:
		for i : int in range(amount):
			inventory.items.remove_at(_get_index_of(item))
	
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
		return inventory.items[index].amount
	
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
	
	inventory.items.append(new_item)


# Returns the index of an item in the inventory array, returning -1 if not found.
func _get_index_of(item : ItemDefinition) -> int:
	for index : int in inventory.items.size():
		if inventory.items[index].definition == item:
			return index
	
	return -1


# Signals that the inventory has been changed somehow.
func _signal_inventory_change() -> void:
	inventory.current_weight = _calculate_weight()
	inventory_updated.emit(get_inventory(), inventory.current_weight, inventory.max_weight)


# Calculates current inventory weight.
func _calculate_weight() -> float:
	var new_weight : float = 0.0
	
	for i : InventoryItem in inventory.items:
		new_weight += i.definition.weight * i.amount
	
	return new_weight


## Validation
func _validate() -> void:
	assert(
		inventory.max_weight >= 0.0,
		"Inventory '%s' has an invalid weight capacity of '%s'. Value must be 0.0 or greater."
		% [self, inventory.max_weight]
	)
