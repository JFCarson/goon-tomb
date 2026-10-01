class_name InventoryItemRow
extends Control

## Instanceable scene parent component for presenting inventory items in the
## inventory UI.
##
## This component should never be directly added to the scene tree, and should
## be created via code.


## Components
@onready var container : MarginContainer = $Margin
@onready var background_rect : ColorRect = $Background

@onready var values_hbox : HBoxContainer = container.get_node("Values")

@onready var icon_rect : TextureRect = values_hbox.get_node("Icon")
@onready var name_label : Label = values_hbox.get_node("Name")
@onready var amount_label : Label = values_hbox.get_node("Amount")
@onready var weight_label : Label = values_hbox.get_node("Weight")


## Config
# Stores the background alpha values for when the container is hovered and
# unhovered.
const HOVERED_ALPHA : float = 0.1
const UNHOVERED_ALPHA : float = 0


## Signals
# Signalled when the player has requested to drop this item.
signal request_drop_self(item_definition : ItemDefinition)


## Runtime State
# Store reference to the item that this component displays.
var item_definition : ItemDefinition 

# Stores the hover state of the row.
var is_hovered : bool = false


## Process
func _ready() -> void:
	# Set the container height to fit its children.
	custom_minimum_size.y = container.size.y
	
	# Enforce the background alpha is in its default state.
	background_rect.color.a = UNHOVERED_ALPHA
	
	# Connect mouse entered/exited signals to their relevant functions.
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _input(event: InputEvent) -> void:
	# Handle drop requests for the item.
	if is_hovered and event.is_action_released("use_secondary"):
		request_drop_self.emit(item_definition)


## Public Interface
# Populate the row to report accurate information.
# Note unit weight should be the weight of a single unit of the item, not the
# combined amount of the entire stack.
func populate(item : ItemDefinition, amount : int) -> void:
	var combined_amount : float = amount * item.weight
	item_definition = item
	
	icon_rect.texture = item_definition.icon
	name_label.text = item_definition.name
	name_label.add_theme_color_override("font_color", ItemEnums.rarity_colour[item_definition.rarity])
	amount_label.text = str(amount)
	weight_label.text = str(combined_amount)


## Listeners
# Change the background alpha when hovered to be the hovered value.
func _on_mouse_entered() -> void:
	background_rect.color.a = HOVERED_ALPHA
	is_hovered = true


# Change the background alpha when unhovered to be the unhovered value.
func _on_mouse_exited() -> void:
	background_rect.color.a = UNHOVERED_ALPHA
	is_hovered = false
