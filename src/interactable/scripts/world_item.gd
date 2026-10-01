class_name WorldItem
extends RigidBody3D

## Base class for the world item component.


## Components
@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var collision : CollisionShape3D = $CollisionShape3D
@onready var interactable : Interactable = $Interactable

## Runtime State
@export var data : ItemDefinition
@export var amount : int


## Process
func _ready() -> void:
	# Configure the scene's Interactable instance.
	interactable.set_process_callback(_destroy_scene)
	interactable.set_request_callback(_create_pickup_request)
	interactable.set_prompt_message("Pick up %s x '%s'" % [amount, data.name])
	
	# Set the mesh from config.
	mesh.mesh = data.mesh
	
	# Calculate collision size of the item from the mesh.
	var collision_shape : BoxShape3D = BoxShape3D.new()
	collision_shape.size = data.mesh.get_aabb().size
	collision.shape = collision_shape


## Private Methods
# Destroys the scene.
func _destroy_scene() -> void:
	queue_free()


# Create a request to pick up an item.
func _create_pickup_request() -> InteractionRequest:
	var request := PickUpItemRequest.new()
	
	request.ref = interactable
	request.type = InteractableEnums.ResponseType.PICK_UP
	request.item = data
	request.amount = amount
	
	return request
