class_name PlayerInventoryController
extends EntityController

## Controller for the player's inventory.

## Runtime State
@onready var inventory := EntityInventory.new()
@onready var entity: CharacterBody3D = get_parent() as CharacterBody3D
@onready var inventory_overlay : PlayerInventoryOverlay = $"../ScreenOverlays/PlayerInventory"
@onready var camera : GameCameraController = $"../GameCameraController"

## Public Methods
func _ready() -> void:
	# Listen for changes to the actual inventory data.
	if not inventory.inventory_updated.is_connected(on_inventory_updated):
		inventory.inventory_updated.connect(on_inventory_updated)
	# Listen for item drop requests from the overlay.
	if not inventory_overlay.drop_item.is_connected(on_drop_item):
		inventory_overlay.drop_item.connect(on_drop_item)

# Processes the toggling of the player's inventory.
func process_toggle_inventory() -> void:
	inventory_overlay.toggle_inventory()
	if inventory_overlay.inventory_is_open:
		entity.can_control_self = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		entity.can_control_self = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Listen for changes to the player's inventory.
func on_inventory_updated(inventory_data: Inventory, weight: float, max_weight: float) -> void:
	inventory_overlay.update_inventory(inventory_data, weight, max_weight)

# Returns a copy of the current inventory.
func get_inventory() -> Inventory:
	return inventory.get_inventory()

# Force the inventory to signal an update.
func force_update() -> void:
	inventory.force_update()

# Try to add a number of items to the controlled inventory, returning whether
# the operation was a success.
func add_item(item : ItemDefinition, amount : int) -> bool:
	return inventory.add_item(item, amount)

# Try to remove a number of items from the controlled inventory, returning
# whether the operation was a success.
func remove_item(item : ItemDefinition, amount : int) -> bool:
	return inventory.remove_item(item, amount)

# Listen for requests to drop an item.
func on_drop_item(item_definition : ItemDefinition, amount : int) -> void:
	remove_item(item_definition, amount)
	camera.drop_item_at_shape_cast(item_definition, amount)
