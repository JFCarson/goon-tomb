class_name CreateWorldItem
extends RefCounted

## Processes the creation of WorldItem instances.


## Config
const WORLD_ITEM_SCENE : PackedScene = preload("res://src/interactable/world_item.tscn")


## Public Interface
# Creates a world item at the provided position, and returns the instance.
static func create_item_instance(item : ItemDefinition, amount : int = 1, world_position : Vector3 = Vector3.ZERO) -> WorldItem:
	var world_item_instance : WorldItem = WORLD_ITEM_SCENE.instantiate()
	
	world_item_instance.data = item
	world_item_instance.stack_amount = amount
	world_item_instance.position = world_position
	
	return world_item_instance
