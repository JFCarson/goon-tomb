class_name ItemDefinition
extends Resource

@export_group("Cosmetic")
# Declaration of the cosmetic name of the item.
@export var name : String


@export_group("World")
# Declaration of the mesh for the item when in the world.
@export var mesh : Mesh

# Toggles whether the item can form stacks in the world.
@export var can_stack : bool = false
