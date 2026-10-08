extends Node

## Handles incoming network packets for the client.
##
## This component receives packets from the network handler, decodes recognised
## gameplay packets, and forwards them to the systems that consume them.


## Signals
# Signal that an entity position packet has been received from the server.
signal handle_entity_position(entity_position : EntityPositionPacket)


## Process
func _ready() -> void:
	# Listen for packets received from the server through the network handler.
	NetHandler.on_client_packet.connect(_on_client_packet)


## Private Methods
# Process a packet received from the server.
#
# The first byte of every packet identifies its packet type. The remaining
# data is then passed to the appropriate packet class for decoding.
func _on_client_packet(data : PackedByteArray) -> void:
	var packet_type : Packet.PacketType = data.decode_u8(Packet.type_byte) as Packet.PacketType
	
	match packet_type:
		Packet.PacketType.ENTITY_POSITION:
			var packet : EntityPositionPacket = EntityPositionPacket.new()
			packet.decode(data)
			handle_entity_position.emit(packet)
			
		_:
			push_error("Packet type with index ", data[Packet.type_byte], " unhandled.")
