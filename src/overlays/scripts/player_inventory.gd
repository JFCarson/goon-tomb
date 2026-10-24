class_name PlayerInventoryOverlay
extends Control

## Front end component for the player's inventory.


# Components
@onready var item_container : VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/InventoryScroll/Items
@onready var weight_label : Label = $PanelContainer/MarginContainer/VBoxContainer/Footer/WeightProgressBar/WeightValue/Weight
@onready var weight_max_label : Label = $PanelContainer/MarginContainer/VBoxContainer/Footer/WeightProgressBar/WeightValue/WeightMax
@onready var inventory_controller : PlayerInventoryController = $"../../PlayerInventoryController"

# Config
# Stores reference the the item row scene.
const ITEM_ROW_SCENE : PackedScene = preload("res://src/overlays/inventory_item.tscn")

# Signalled when the player has requested to drop an item.
signal drop_item(item_definition: ItemDefinition, amount: int)

# Runtime State
# Stores whether the inventory is open.
var inventory_is_open : bool = false
# Stores a copy of the inventory, which is displayed by the component.
# Creates an empty inventory on ready, which can be replaced.
var current_inventory: Inventory = null
# Stores the currently displayed weight values of the inventory.
var weight_value : float = 0.0
var weight_max_value : float = 0.0

# Process
# Hide the component on ready, and propogate the state.
func _ready() -> void:
	visible = inventory_is_open

## Public Interface
# Toggle visibility of the inventory.
func toggle_inventory() -> void:
	if inventory_is_open:
		self.visible = false
		inventory_is_open = false
	else:
		self.visible = true
		inventory_is_open = true
		
# Update the component to reflect the state of the inventory.
func update_inventory(
	inventory_data: Inventory,
	weight: float,
	max_weight: float
) -> void:
	current_inventory = inventory_data
	weight_value = weight
	weight_max_value = max_weight
	_propogate_state()

## Private Methods
# Propogates the state of the component to the visual elements, and sets up
func _on_inventory_updated() -> void:
	_propogate_state()
# listeners for each item.
func _propogate_state() -> void:
	weight_label.text = str(weight_value)
	weight_max_label.text = str(weight_max_value)
	
	for i in item_container.get_children():
		i.queue_free()
	
	if not current_inventory.items.is_empty():
		for i in current_inventory.items:
			var instance := ITEM_ROW_SCENE.instantiate()
			
			item_container.add_child(instance)
		
			instance.populate(i.definition, i.amount)
			
			_connect_row_signals(instance)

## Listeners
# Connect signals to listener functions for item rows.
func _connect_row_signals(instance : InventoryItemRow) -> void:
	# Create a listener for item drop requests.
	instance.request_drop_self.connect(_on_request_item_drop)

# Handles a request for an item to be dropped
func _on_request_item_drop(item_definition : ItemDefinition) -> void:
	drop_item.emit(item_definition, 1)
