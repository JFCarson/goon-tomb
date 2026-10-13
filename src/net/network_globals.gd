extends Node

## Coordinates packet encoding, decoding, and dispatch for the client and server.


## Config
# Directory containing the packet definition resources.
const packet_definition_directory : String = "res://src/net/packet/definitions/"


## Signals
# Emitted when the client receives a valid, decoded packet from the server.
signal handle_client_packet(packet : Dictionary)

# Emitted when the server receives a valid, decoded packet from a client.
signal handle_server_packet(peer_id : int, packet : Dictionary)


## Runtime
# Persistent processor instance that stores registered packet definitions
# and handles encoding and decoding for the lifetime of this node.
var packet_processor : PacketProcessor = PacketProcessor.new()


## Process
# Loads packet definitions and connects the appropriate receive signal
# for this application's network role.
func _ready() -> void:
	_load_packet_definitions()

	if multiplayer.is_server():
		NetHandler.on_server_packet.connect(_on_server_packet)
	else:
		NetHandler.on_client_packet.connect(_on_client_packet)


## Public Interface
# Encodes and sends a packet to the specified peer.
func send_packet(packet_type_id : int, values : Dictionary, target_peer_id : int = NetHandler.server_id, entity_id : int = 0) -> void:
	# Retrieve the definition to confirm the packet type is registered and
	# determine which transfer mode should be used.
	var definition : Packet = packet_processor.get_definition(packet_type_id)

	if definition == null:
		push_error("Cannot send an unregistered packet type.")
		return

	# Convert the supplied field values and optional entity ID into bytes.
	var data : PackedByteArray = packet_processor.encode(packet_type_id, values, entity_id)

	# Do not attempt to send if encoding failed.
	if data.is_empty():
		return

	# Hand the encoded bytes to NetHandler for transport.
	NetHandler.send_bytes(data, target_peer_id, definition.transfer_mode)


# Sends a packet to the server using the server's peer ID.
func send_packet_to_server(packet_type_id : int, values : Dictionary, entity_id : int = 0) -> void:
	send_packet(packet_type_id, values, NetHandler.server_id, entity_id)


# Sends a packet to all connected peers using peer ID zero as the broadcast target.
func broadcast_packet(packet_type_id : int, values : Dictionary, entity_id : int = 0) -> void:
	send_packet(packet_type_id, values, 0, entity_id)


## Private Methods
# Loads and registers all packet definition resources in the configured directory.
func _load_packet_definitions() -> void:
	var directory : DirAccess = DirAccess.open(packet_definition_directory)

	# Stop loading definitions if the directory cannot be opened.
	if directory == null:
		push_error("Failed to open packet definition directory: " + packet_definition_directory)
		return

	# Begin scanning the directory's entries.
	directory.list_dir_begin()

	var file_name : String = directory.get_next()

	while not file_name.is_empty():
		# Load .tres resources only; ignore directories and other file types.
		if not directory.current_is_dir() and file_name.ends_with(".tres"):
			var path : String = packet_definition_directory.path_join(file_name)
			var definition : Packet = load(path) as Packet

			# Report resources that fail to load.
			if definition == null:
				push_error("Failed to load packet definition: " + path)
			# Register successfully loaded definitions with the processor.
			elif not packet_processor.register_definition(definition):
				push_error("Failed to register packet definition: " + path)

		# Advance to the next directory entry.
		file_name = directory.get_next()

	# Finish scanning and release the directory listing.
	directory.list_dir_end()


# Decodes an incoming packet received by a client and emits it for the
# relevant gameplay systems to handle.
func _on_client_packet(data : PackedByteArray) -> void:
	var packet : Dictionary = packet_processor.decode(data)

	# Ignore packets that failed validation or decoding.
	if packet.is_empty():
		return

	handle_client_packet.emit(packet)


# Decodes an incoming packet received by the server and includes the sender's
# peer ID when notifying systems that handle client-originated packets.
func _on_server_packet(peer_id : int, data : PackedByteArray) -> void:
	var packet : Dictionary = packet_processor.decode(data)

	# Ignore packets that failed validation or decoding.
	if packet.is_empty():
		return

	handle_server_packet.emit(peer_id, packet)
