extends Node


# Signals
## Emitted when a decoded packet has been received by the client, passed
## direction validation, and been accepted by the session layer.
signal handle_client_packet(packet: DecodedPacket)

## Emitted when a decoded packet has been received by the server, passed
## direction validation, and been accepted by the session layer.
signal handle_server_packet(sender_peer_id: int, packet: DecodedPacket)


# Config
## Directory containing the .tres resources that define the network packet
## types supported by this build.
const packet_definitions_path : String = "res://src/net/packet/definitions/"


# State
## Packet processor responsible for registering packet definitions and
## encoding outgoing packets or decoding incoming packet data.
var packet_processor : PacketProcessor


## Initializes packet handling by loading all packet definitions and
## subscribing to the transport layer's incoming packet signals.
func _ready() -> void:
	_load_packet_definitions()
	
	NetworkHandler.on_client_packet.connect(_on_client_packet)
	NetworkHandler.on_server_packet.connect(_on_server_packet)


# Public Interface
## Loads packet definitions into a temporary processor.
##
## The processor is only assigned after every definition has loaded and
## registered successfully, preventing a partially loaded packet registry.
func _load_packet_definitions() -> void:
	var loaded_processor := PacketProcessor.new()
	var dir := DirAccess.open(packet_definitions_path)
	if dir == null:
		push_error("Failed to open packet definitions directory: %s" % packet_definitions_path)
		return
		
	dir.list_dir_begin()
	
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource_path : String = packet_definitions_path + file_name
			var definition := load(resource_path) as Packet
			if definition == null:
				push_error("Failed to load packet definition: %s" % resource_path)
				dir.list_dir_end()
				return
				
			if not loaded_processor.register_definition(definition):
				push_error("Failed to register packet definition: %s" % resource_path)
				dir.list_dir_end()
				return
				
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
	packet_processor = loaded_processor


## Encodes and sends a packet from the client to the server.
##
## Only packets permitted by their configured direction and the current
## session state may be sent.
func send_packet_to_server(packet_type_id : PacketEnums.Type, values : Dictionary, entity_id : int = 0) -> void:
	if packet_processor == null:
		push_warning("Cannot send packet: packet processor is not initialized.")
		return
		
	var definition := packet_processor.get_definition(packet_type_id)
	if definition == null:
		push_warning("Cannot send packet: unknown packet type '%s'." % packet_type_id)
		return
		
	if not _is_direction_allowed(definition, PacketEnums.Direction.CLIENT_TO_SERVER, PacketEnums.DirectionContext.SEND_TO_SERVER):
		return
		
	if not NetworkSession.can_send_packet_to_server(packet_type_id):
		return
		
	var encoded_packet := packet_processor.encode(packet_type_id, values, entity_id)
	if encoded_packet.is_empty():
		return
		
	NetworkHandler.send_bytes_to_server(encoded_packet, definition.transfer_mode)


## Encodes and sends a packet from the server to a specific peer.
##
## Returns true when the packet is accepted for sending, or false if
## validation, session readiness, or encoding prevents transmission.
func send_packet_to_peer(packet_type_id : PacketEnums.Type, values : Dictionary, target_peer_id : int, entity_id : int = 0) -> bool:
	if packet_processor == null:
		push_warning("Cannot send packet: packet processor is not initialized.")
		return false
		
	var definition := packet_processor.get_definition(packet_type_id)
	if definition == null:
		push_warning("Cannot send packet: unknown packet type '%s'." % packet_type_id)
		return false
		
	if not _is_direction_allowed(definition, PacketEnums.Direction.SERVER_TO_CLIENT, PacketEnums.DirectionContext.SEND_TO_PEER):
		return false
		
	if not NetworkSession.can_send_packet_to_peer(packet_type_id, target_peer_id):
		return false
		
	var encoded_packet := packet_processor.encode(packet_type_id, values, entity_id)
	if encoded_packet.is_empty():
		return false
		
	NetworkHandler.send_bytes_to_peer(encoded_packet, target_peer_id, definition.transfer_mode)
	
	return true


## Encodes a packet once and sends it to every ready peer.
##
## Handshake readiness is checked per peer, so pending or rejected peers
## do not receive gameplay broadcasts.
func broadcast_packet(packet_type_id : PacketEnums.Type, values : Dictionary, entity_id : int = 0) -> void:
	if packet_processor == null:
		push_warning("Cannot broadcast packet: packet processor is not initialized.")
		return
		
	var definition := packet_processor.get_definition(packet_type_id)
	if definition == null:
		push_warning("Cannot broadcast packet: unknown packet type '%s'." % packet_type_id)
		return
		
	if not _is_direction_allowed(definition, PacketEnums.Direction.SERVER_TO_CLIENT, PacketEnums.DirectionContext.BROADCAST):
		return
		
	var encoded_packet := packet_processor.encode(packet_type_id, values, entity_id)
	if encoded_packet.is_empty():
		return
		
	if NetworkHandler.multiplayer_peer == null or not multiplayer.is_server():
		return
		
	# Iterate over tracked peers and only send to peers that are ready.
	for peer_id : int in NetworkSession.peer_states:
		if not NetworkSession.can_send_packet_to_peer(packet_type_id, peer_id):
			continue
			
		NetworkHandler.send_bytes_to_peer(encoded_packet, peer_id, definition.transfer_mode)


# Private Methods
## Checks whether a packet's configured direction permits the operation.
##
## AGNOSTIC packets may travel in either direction. All other packets must
## match the expected direction for the send or receive operation.
func _is_direction_allowed(definition : Packet, expected_direction : PacketEnums.Direction, context : PacketEnums.DirectionContext) -> bool:
	if definition == null:
		push_warning("Rejected packet: packet definition is missing.")
		return false
		
	if definition.direction == PacketEnums.Direction.AGNOSTIC:
		return true
		
	if definition.direction == expected_direction:
		return true
		
	push_warning("Rejected packet type '%s': direction mismatch in context '%s'." % [definition.packet_type_id, PacketEnums.DirectionContext.keys()[context]])
	
	return false


# Signal Methods
## Handles bytes received by the client.
##
## Decodes the packet, validates its direction and routes it through the
## session layer before exposing it to gameplay listeners.
func _on_client_packet(sender_peer_id : int, data : PackedByteArray) -> void:
	if packet_processor == null:
		push_warning("Rejected incoming packet: packet processor is not initialized.")
		return
		
	var packet := packet_processor.decode(data)
	if packet == null:
		return
		
	packet.sender_peer_id = sender_peer_id
	
	if not _is_direction_allowed(packet_processor.get_definition(packet.packet_type_id), PacketEnums.Direction.SERVER_TO_CLIENT, PacketEnums.DirectionContext.RECEIVE_FROM_SERVER):
		return
		
	if not NetworkSession.route_client_packet(packet):
		return
		
	handle_client_packet.emit(packet)


## Handles bytes received by the server.
##
## Decodes the packet, validates its direction and routes it through the
## session layer before exposing it to gameplay listeners.
func _on_server_packet(sender_peer_id : int, data : PackedByteArray) -> void:
	if packet_processor == null:
		push_warning("Rejected incoming packet: packet processor is not initialized.")
		return
		
	var packet := packet_processor.decode(data)
	if packet == null:
		return
		
	packet.sender_peer_id = sender_peer_id
	
	if not _is_direction_allowed(packet_processor.get_definition(packet.packet_type_id), PacketEnums.Direction.CLIENT_TO_SERVER, PacketEnums.DirectionContext.RECEIVE_FROM_CLIENT):
		return
		
	if not NetworkSession.route_server_packet(packet):
		return
		
	handle_server_packet.emit(sender_peer_id, packet)
