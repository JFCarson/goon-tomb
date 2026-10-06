extends Node

## Handles network peer identity and incoming packets for the client.
##
## This component receives packets from the network handler, processes peer ID
## assignments, and forwards recognised gameplay packets to the systems that
## consume them.


## Signals
# Signals that the local client has been assigned its network peer ID.
signal handle_local_peer_id_assignment(peer_id : int)

# Signals that another client has been identified on the network.
signal handle_remote_peer_id_assignment(peer_id : int)

# Signals that an entity position packet has been received from the server.
signal handle_entity_position(entity_position : EntityPositionPacket)


## Runtime
# Network peer ID assigned to this client.
#
# A value of -1 indicates that the client has not yet received its peer ID
# assignment from the server.
var peer_id : int = -1

# Network peer IDs currently known to this client.
#
# These IDs represent other clients connected to the server and are used to
# identify their corresponding network peers.
var remote_peer_ids : Array[int]


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
	var packet_type : int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.PEER_ID_ASSIGNMENT:
			_manage_peer_ids(PeerIDAssignmentPacket.create_from_data(data))
			
		PacketInfo.PACKET_TYPE.ENTITY_POSITION:
			handle_entity_position.emit(EntityPositionPacket.create_from_data(data))
			
		_:
			push_error("Packet type with index ", data[0], " unhandled.")


# Process a peer ID assignment received from the server.
#
# The first assignment received by this client establishes its own network
# peer ID. The packet also contains the peer IDs currently known by the
# server.
#
# Subsequent assignments represent newly connected remote peers.
func _manage_peer_ids(peer_id_assignment : PeerIDAssignmentPacket) -> void:
	if peer_id == -1:
		# The first assignment received establishes this client's own peer ID.
		peer_id = peer_id_assignment.peer_id
		handle_local_peer_id_assignment.emit(peer_id)
		
		# Store the peer IDs currently known by the server.
		remote_peer_ids = peer_id_assignment.remote_peer_ids
		
		# Notify other systems about each remote peer.
		for remote_peer_id in remote_peer_ids:
			# Do not treat this client's own peer ID as a remote peer.
			if remote_peer_id == peer_id:
				continue
			
			handle_remote_peer_id_assignment.emit(remote_peer_id)
	else:
		# Once the local peer ID has been assigned, any subsequent assignment
		# represents a newly connected remote peer.
		remote_peer_ids.append(peer_id_assignment.peer_id)
		handle_remote_peer_id_assignment.emit(peer_id_assignment.peer_id)
