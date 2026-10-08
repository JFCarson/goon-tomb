extends Node

## Handles incoming network packets for the server.
##
## This component receives packets from connected clients, decodes recognised
## gameplay packets, and forwards them to the systems that consume them.


## Signals
# Signal that an entity position packet has been received from a client.
#
# The peer ID identifies which network client sent the packet, while the
# EntityPositionPacket contains the entity position data.
signal handle_entity_position(peer_id : int, entity_position : EntityPositionPacket)


## Process
func _ready() -> void:
	# Listen for packets received from connected clients through the network
	# handler.
	NetHandler.on_server_packet.connect(_on_server_packet)


## Private Methods
# Handles a packet received from a connected client.
#
# The peer ID is supplied directly by Godot's MultiplayerAPI through the
# network handler. The first byte of every packet identifies its packet type.
# The remaining data is then passed to the appropriate packet class for
# decoding.
func _on_server_packet(peer_id : int, data : PackedByteArray) -> void:
	var packet_type : Packet.PacketType = data.decode_u8(Packet.type_byte) as Packet.PacketType
	
	match packet_type:
		Packet.PacketType.ENTITY_POSITION:
			var packet : EntityPositionPacket = EntityPositionPacket.new()
			packet.decode(data)
			handle_entity_position.emit(peer_id, packet)
		
		_:
			push_error("Packet type with index ", data[Packet.type_byte], " unhandled.")
