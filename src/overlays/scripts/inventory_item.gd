class_name InventoryItemRow
extends HBoxContainer

## Instanceable scene parent component for presenting inventory items in the
## inventory UI.


## Components
@onready var icon_rect : TextureRect = $Icon
@onready var name_label : Label = $Name
@onready var amount_label : Label = $Amount
@onready var weight_label : Label = $Weight


## Public Interface
# Populate the row to report accurate information.
# Note unit weight should be the weight of a single unit of the item, not the
# combined amount of the entire stack.
func populate(item : ItemDefinition, amount : int) -> void:
	var combined_amount : float = amount * item.weight
	
	icon_rect.texture = item.icon
	name_label.text = item.name
	name_label.add_theme_color_override("font_color", ItemEnums.rarity_colour[item.rarity])
	amount_label.text = str(amount)
	weight_label.text = str(combined_amount)
