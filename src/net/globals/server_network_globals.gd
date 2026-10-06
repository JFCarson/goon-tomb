extends Node

## Handles network peer identity and incoming packets for the server.
##
## This component tracks the network peers currently connected to the server,
## responds to connection changes, and forwards recognised gameplay packets
## to the systems that consume them.


## Signals
# Signals that an entity position packet has been received from a client.
#
# The peer ID identifies which network client sent the packet, while the
# EntityPositionPacket contains the entity position data.
signal handle_entity_position(peer_id : int, entity_position : EntityPositionPacket)


## Runtime
# Network peer IDs currently connected to the server.
var peer_ids : Array[int]


## Process
func _ready() -> void:
	# Listen for client connection and disconnection events from the network
	# handler.
	NetHandler.on_peer_connected.connect(_on_peer_connected)
	NetHandler.on_peer_disconnected.connect(_on_peer_disconnected)
	
	# Listen for packets received from connected clients.
	NetHandler.on_server_packet.connect(_on_server_packet)


## Private Methods
# Handles a new client connecting to the server.
#
# Adds the client's peer ID to the list of currently connected peers and
# broadcasts the current peer ID information to all connected clients.
func _on_peer_connected(peer_id : int) -> void:
	peer_ids.append(peer_id)
	
	PeerIDAssignmentPacket.create(peer_id,peer_ids).broadcast(NetHandler.connection)


# Handles a client disconnecting from the server.
#
# Removes the client's peer ID from the list of currently connected peers.
func _on_peer_disconnected(peer_id : int) -> void:
	peer_ids.erase(peer_id)
	
	# NOTE: NEED TO CREATE A PEER ID UNASSIGNMENT PACKET.


# Handles a packet received from a connected client.
#
# The first byte of every packet identifies its packet type. The remaining
# data is then passed to the appropriate packet class for decoding.
func _on_server_packet(peer_id : int, data : PackedByteArray) -> void:
	var packet_type : int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ENTITY_POSITION:
			handle_entity_position.emit(peer_id, EntityPositionPacket.create_from_data(data))
		
		_:
			push_error("Packet type with index ", data[0], " unhandled.")
