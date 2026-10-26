class_name RemoteCharacterController
extends Node

## Controls the presentation of a remote player character.
##
## This component does not read local input or simulate authoritative
## movement. It receives replicated state and smoothly updates the
## character representation on the owning client.


# Configuration
## How quickly the character interpolates towards its replicated position.
const interpolation_speed : float = 12.0


# Components
## Character body whose replicated transform is being presented.
@onready var entity : CharacterBody3D = get_parent() as CharacterBody3D


# Runtime
## Position received from the authoritative server.
var target_position : Vector3

## Rotation received from the authoritative server.
var target_rotation : float

## Whether an initial replicated transform has been received.
var has_received_state : bool = false


# Process
## Initialises the controller with the character's current transform.
func _ready() -> void:
	assert(entity != null, "RemoteCharacterController must be a child of a CharacterBody3D.")
	
	target_position = entity.global_position
	target_rotation = entity.global_rotation.y


## Smoothly interpolates the character towards its latest replicated transform.
func _physics_process(delta : float) -> void:
	if not has_received_state:
		return
		
	var weight : float = 1.0 - exp(-interpolation_speed * delta)
	
	entity.global_position = entity.global_position.lerp(target_position, weight)
	
	var current_rotation : float = entity.global_rotation.y
	entity.global_rotation.y = lerp_angle(current_rotation, target_rotation, weight)


# Public Interface
## Applies a replicated transform received from the authoritative server.
func apply_replicated_transform(position : Vector3, rotation : float) -> void:
	target_position = position
	target_rotation = rotation
	
	if not has_received_state:
		entity.global_position = position
		entity.global_rotation.y = rotation
		has_received_state = true


## Receives entity packets routed by NetworkEntityManager.
##
## Position replication packet handling will be added when the packet
## definition and payload format for transform updates are implemented.
func handle_network_packet(packet : DecodedPacket) -> void:
	if packet == null:
		return
