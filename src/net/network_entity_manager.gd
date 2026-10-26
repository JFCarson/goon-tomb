extends Node

## Routes decoded entity packets to their registered network entities.
##
## This manager does not decode packets or create entities. It maintains
## a registry of existing entities and dispatches incoming entity packets
## to the appropriate entity through its handle_network_packet() method.


# Config
## Maximum entity ID supported by the packet protocol.
const max_entity_id : int = 65535


# Runtime
## Network entities indexed by their unique entity ID.
var entities : Dictionary[int, Node] = {}


# Process
## Connects to the existing networking layer to receive decoded packets.
func _ready() -> void:
	if not NetworkGlobals.handle_client_packet.is_connected(_on_client_packet):
		NetworkGlobals.handle_client_packet.connect(_on_client_packet)
		
	if not NetworkGlobals.handle_server_packet.is_connected(_on_server_packet):
		NetworkGlobals.handle_server_packet.connect(_on_server_packet)


# Public Interface
## Registers an existing node as a network entity.
## Returns true when registration succeeds.
func register_entity(entity_id : int, entity : Node) -> bool:
	if entity_id < 1 or entity_id > 65535:
		push_warning("Cannot register network entity: entity ID is outside the valid range.")
		return false
		
	if not is_instance_valid(entity):
		push_warning("Cannot register network entity: supplied node is invalid.")
		return false
		
	if entities.has(entity_id):
		var existing_entity : Node = entities[entity_id]
		
		if is_instance_valid(existing_entity):
			push_warning("Cannot register network entity: entity ID %s is already registered." % entity_id)
			return false
			
		# Replace stale entries left by nodes that have been freed.
		unregister_entity(entity_id)
		
	entities[entity_id] = entity
	return true


## Unregisters an entity by its unique entity ID.
## Returns true when an entry was removed.
func unregister_entity(entity_id : int) -> bool:
	if not entities.has(entity_id):
		return false
		
	entities.erase(entity_id)
	return true


## Returns the registered entity for an ID, or null if it does not exist.
func get_entity(entity_id : int) -> Node:
	if not entities.has(entity_id):
		return null
		
	var entity : Node = entities[entity_id]
	
	if not is_instance_valid(entity):
		unregister_entity(entity_id)
		return null
		
	return entity


## Returns whether a valid entity is registered under the supplied ID.
func has_entity(entity_id : int) -> bool:
	return get_entity(entity_id) != null


## Dispatches an entity packet to its registered entity.
## Returns true when the packet is successfully dispatched.
func dispatch_packet(packet : DecodedPacket) -> bool:
	if packet == null:
		push_warning("Cannot dispatch a null network packet.")
		return false
		
	if packet.category != PacketEnums.Category.ENTITY:
		return false
		
	# Lifecycle packets are handled by their respective managers.
	if packet.packet_type_id in PacketEnums.entity_lifecycle_types:
		return false
		
	if packet.entity_id < 1:
		push_warning("Received an entity packet with an invalid entity ID.")
		return false
		
	var entity : Node = get_entity(packet.entity_id)
	
	if entity == null:
		push_warning("Received packet type %s for unregistered entity %s." % [packet.packet_type_id, packet.entity_id])
		return false
		
	if not entity.has_method("handle_network_packet"):
		push_warning("Network entity %s does not implement handle_network_packet()." % packet.entity_id)
		return false
		
	entity.handle_network_packet(packet)
	return true


## Removes invalid entity references from the registry.
func prune_invalid_entities() -> void:
	var entity_ids : Array[int] = []
	
	for entity_id : int in entities:
		entity_ids.append(entity_id)
		
	for entity_id : int in entity_ids:
		if not is_instance_valid(entities[entity_id]):
			unregister_entity(entity_id)


# Signal Methods
## Routes packets received by a client from the server.
func _on_client_packet(packet : DecodedPacket) -> void:
	dispatch_packet(packet)


## Routes packets received by the server from a client.
func _on_server_packet(_peer_id : int, packet : DecodedPacket) -> void:
	dispatch_packet(packet)
