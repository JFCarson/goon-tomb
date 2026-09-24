class_name ItemDefinition
extends Resource

## Base class for the definition for the metadata for an item.


@export_group("Cosmetic")
# Declaration of the cosmetic name of the item.
@export var name : String

# Declaration of the cosmetic description for the item.
@export var description : PackedStringArray


@export_group("Functional")
# Declaration of what category of item this is.
@export var category : ItemEnums.Category

# Declaration of the rarity of the item.
@export var rarity : ItemEnums.Rarity

# Declaration of the weight of the item.
@export var weight : float 


@export_group("World")
# Declaration of the mesh for the item when in the world.
@export var mesh : Mesh

# Toggles whether the item can form stacks in the world.
@export var can_stack : bool = false
