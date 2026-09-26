class_name WorldItem
extends Interactable


## Configuration
@export var data : ItemDefinition


## Components
@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var collision : CollisionShape3D = $CollisionShape3D


## Runtime State
var stack_amount = 1


## Process
# Populates the instance of the class on ready.
func _ready() -> void:
	# Set the interaction prompt message.
	if data.can_stack:
		prompt_message = "Pick up %s x '%s'" % [stack_amount, data.name]
	else:
		prompt_message = "Pick up '%s'" % data.name
	
	# Set the mesh from config.
	mesh.mesh = data.mesh
	
	# Calculate collision size of the item from the mesh.
	var collision_shape : BoxShape3D = BoxShape3D.new()
	collision_shape.size = data.mesh.get_aabb().size
	collision.shape = collision_shape


## Public Interface
# Once the interaction has been proven valid, handle the despawning of the item
# from the world.
func process_interaction() -> void:
	queue_free()
	

## Private Methods
# Creates a request to pick the item up. Called by interact().
func _create_interaction_request() -> InteractionRequest:
	var request := PickUpItemRequest.new()
	
	request.ref = self
	request.type = InteractableEnums.ResponseType.PICK_UP
	request.item = data
	request.amount = stack_amount
	
	return request
