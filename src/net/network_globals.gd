extends Node

## Handles incoming network packets for both the client and server.
##
## Receives packets from the network handler, decodes recognised gameplay
## packets, and forwards them to the systems that consume them.


## Signals
# Signal that a decoded packet has been received by the client.
signal handle_client_packet(packet : Packet)

# Signal that a decoded packet has been received by the server.
#
# The peer ID identifies which network client sent the packet.
signal handle_server_packet(peer_id : int, packet : Packet)


## Process
func _ready() -> void:
	# Connect to the appropriate incoming packet signal for this application.
	if multiplayer.is_server():
		NetHandler.on_server_packet.connect(_on_server_packet)
	else:
		NetHandler.on_client_packet.connect(_on_client_packet)


## Private Methods
# Process a packet received by the client.
func _on_client_packet(data : PackedByteArray) -> void:
	var packet : Packet = _decode_packet(data)

	if packet == null:
		return

	handle_client_packet.emit(packet)


# Process a packet received by the server.
#
# The peer ID identifies which network client sent the packet.
func _on_server_packet(peer_id : int, data : PackedByteArray) -> void:
	var packet : Packet = _decode_packet(data)

	if packet == null:
		return

	handle_server_packet.emit(peer_id, packet)


# Decode a packet based on its packet type.
#
# Returns null if the data is empty, the packet type is unrecognised, or
# decoding fails.
func _decode_packet(data : PackedByteArray) -> Packet:
	if data.is_empty():
		push_error("Received an empty packet.")
		return null

	var packet_type : Packet.PacketType = data.decode_u8(Packet.type_byte) as Packet.PacketType
	var packet : Packet

	match packet_type:
		Packet.PacketType.ENTITY_POSITION:
			packet = EntityPositionPacket.new()

		_:
			push_error("Packet type with index %s unhandled." % data[Packet.type_byte])
			return null

	if not packet.decode(data):
		return null

	return packet
