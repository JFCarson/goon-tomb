extends Node

## Coordinates packet encoding, decoding, and dispatch for the client and server.


# Config
## Directory containing the packet definition resources.
const packet_definition_directory : String = "res://src/net/packet/definitions/"


# Signals
## Emitted when the client receives a valid, decoded packet from the server.
signal handle_client_packet(packet : DecodedPacket)

## Emitted when the server receives a valid, decoded packet from a client.
signal handle_server_packet(peer_id : int, packet : DecodedPacket)


# Runtime
## Persistent processor instance that stores registered packet definitions
## and handles encoding and decoding for the lifetime of this node.
var packet_processor : PacketProcessor = PacketProcessor.new()

## Indicates that all packet definitions have loaded successfully, and the
## application is ready for networking.
var is_ready_for_networking : bool = false


# Process
## Loads packet definitions and connects to both transport packet signals.
func _ready() -> void:
	if not _load_packet_definitions():
		push_error("NetworkGlobals initialisation failed: packet definitions could not be loaded.")
		return
		
	is_ready_for_networking = true
	
	if not NetHandler.on_server_packet.is_connected(_on_server_packet):
		NetHandler.on_server_packet.connect(_on_server_packet)
		
	if not NetHandler.on_client_packet.is_connected(_on_client_packet):
		NetHandler.on_client_packet.connect(_on_client_packet)


# Public Interface
## Encodes and sends a packet from a client to the server.
func send_packet_to_server(packet_type_id : int, values : Dictionary, entity_id : int = 0) -> void:
	if not is_ready_for_networking:
		push_error("Cannot send packet: NetworkGlobals is not ready for networking.")
		return
	
	if not NetSession.can_send_packet_to_server(packet_type_id):
		push_warning("Cannot send packet: client session is not ready.")
		return
	
	var data : PackedByteArray = _encode_packet(packet_type_id, values, entity_id)
	if data.is_empty():
		return
		
	var definition : Packet = packet_processor.get_definition(packet_type_id)
	NetHandler.send_bytes_to_server(data, definition.transfer_mode)


## Encodes and sends a packet from the server to one client.
## Returns true only when the transport successfully sends the packet.
func send_packet_to_peer(packet_type_id : int, values : Dictionary, target_peer_id : int, entity_id : int = 0) -> bool:
	if not is_ready_for_networking:
		push_error("Cannot send packet: NetworkGlobals is not ready for networking.")
		return false
		
	if not NetSession.can_send_packet_to_peer(packet_type_id, target_peer_id):
		push_warning("Cannot send packet: target peer has not completed its handshake.")
		return false
	
	var data : PackedByteArray = _encode_packet(packet_type_id, values, entity_id)
	if data.is_empty():
		return false
		
	var definition : Packet = packet_processor.get_definition(packet_type_id)
	if definition == null:
		return false
		
	return NetHandler.send_bytes_to_peer(data, target_peer_id, definition.transfer_mode)


## Encodes and sends a packet to every client that has completed its handshake.
func broadcast_packet(packet_type_id : int, values : Dictionary, entity_id : int = 0) -> void:
	if not is_ready_for_networking:
		push_error("Cannot send packet: NetworkGlobals is not ready for networking.")
		return
		
	if NetHandler.multiplayer_peer == null or not multiplayer.is_server():
		push_error("Cannot broadcast packet: this instance is not an active server.")
		return
		
	# Handshake packets must always be sent to a specific peer.
	if packet_type_id == PacketEnums.Type.CLIENT_HANDSHAKE or packet_type_id == PacketEnums.Type.SERVER_HANDSHAKE:
		push_error("Cannot broadcast handshake packets.")
		return
		
	var definition : Packet = packet_processor.get_definition(packet_type_id)
	if definition == null:
		push_error("Cannot broadcast an unregistered packet type.")
		return
		
	for peer_id : int in multiplayer.get_peers():
		if NetSession.is_peer_ready(peer_id):
			send_packet_to_peer(packet_type_id, values, peer_id, entity_id)


# Private Methods
## Encodes a packet using its registered definition.
## Returns an empty array if the packet cannot be encoded.
func _encode_packet(packet_type_id : int, values : Dictionary, entity_id : int) -> PackedByteArray:
	var definition : Packet = packet_processor.get_definition(packet_type_id)
	
	if definition == null:
		push_error("Cannot send an unregistered packet type.")
		return PackedByteArray()
		
	return packet_processor.encode(packet_type_id, values, entity_id)


## Loads and registers all packet definition resources in the configured directory.
## Replaces the active processor only if every definition loads successfully.
func _load_packet_definitions() -> bool:
	var directory : DirAccess = DirAccess.open(packet_definition_directory)
	
	# Stop loading definitions if the directory cannot be opened.
	if directory == null:
		push_error("Failed to open packet definition directory: " + packet_definition_directory)
		return false
		
	var error : Error = directory.list_dir_begin()
	if error != OK:
		push_error("Failed to list packet definition directory: " + packet_definition_directory)
		return false
		
	# Register definitions in a temporary processor to prevent partial registration.
	var temporary_processor : PacketProcessor = PacketProcessor.new()
	
	# Track whether all definitions load and register successfully.
	var all_definitions_valid : bool = true
	var definition_count : int = 0
	
	var file_name : String = directory.get_next()
	
	while not file_name.is_empty():
		# Load .tres resources only; ignore directories and other file types.
		if not directory.current_is_dir() and file_name.ends_with(".tres"):
			var path : String = packet_definition_directory.path_join(file_name)
			var definition : Packet = load(path) as Packet
			
			# Report resources that fail to load.
			if definition == null:
				push_error("Failed to load packet definition: " + path)
				all_definitions_valid = false
				
			# Register successfully loaded definitions with the temporary processor.
			elif not temporary_processor.register_definition(definition):
				push_error("Failed to register packet definition: " + path)
				all_definitions_valid = false
				
			else:
				definition_count += 1
				
		# Advance to the next directory entry.
		file_name = directory.get_next()
		
	# Finish scanning and release the directory listing.
	directory.list_dir_end()
	
	# Reject an empty directory rather than starting without packet definitions.
	if definition_count == 0:
		push_error("No packet definitions were loaded from: " + packet_definition_directory)
		all_definitions_valid = false
	
	# Keep the existing processor unchanged if any definition failed.
	if not all_definitions_valid:
		return false
		
	# Commit the complete registry only after every definition succeeds.
	packet_processor = temporary_processor
	return true


# Signal Methods
## Decodes an incoming packet received by a client and routes it through
## the session layer before emitting it for gameplay systems.
func _on_client_packet(sender_peer_id : int, data : PackedByteArray) -> void:
	if not is_ready_for_networking:
		push_error("Cannot process packet: NetworkGlobals is not ready for networking.")
		return
		
	var packet : DecodedPacket = packet_processor.decode(data)
	if packet == null:
		return
	
	# Preserve the sender identity supplied by the transport layer.
	packet.sender_peer_id = sender_peer_id
	
	if NetSession.route_client_packet(packet):
		handle_client_packet.emit(packet)


## Decodes an incoming packet received by the server and attaches the sender's
## peer ID before routing it to the session layer.
func _on_server_packet(peer_id : int, data : PackedByteArray) -> void:
	if not is_ready_for_networking:
		push_error("Cannot process packet: NetworkGlobals is not ready for networking.")
		return

	var packet : DecodedPacket = packet_processor.decode(data)
	if packet == null:
		return

	# Preserve the sender identity supplied by the transport layer.
	packet.sender_peer_id = peer_id

	if NetSession.route_server_packet(packet):
		handle_server_packet.emit(packet.sender_peer_id, packet)
