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
	var collision_shape : Shape3D = data.collision_shape
	var mesh_size : Vector3 = data.mesh.get_aabb().size

	if collision_shape is BoxShape3D:
		collision_shape.size = mesh_size
	else:
		var radius : float = maxf(mesh_size.x, mesh_size.z) / 2.0
		
		if collision_shape is CapsuleShape3D or collision_shape is CylinderShape3D:
			collision_shape.radius = radius
			collision_shape.height = maxf(mesh_size.y, radius * 2.0)
		elif collision_shape is SphereShape3D:
			collision_shape.radius = maxf(mesh_size.x, maxf(mesh_size.y, mesh_size.z)) / 2.0
		else:
			assert(false, "'%s' is not a good collision shape for a world item '%s'. Please reconsider." % [collision_shape.get_class(), data.name])
	
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
