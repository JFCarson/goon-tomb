class_name PeerIDAssignmentPacket
extends PacketInfo

## Packet used to communicate network peer IDs to a client.
##
## The packet contains the peer ID assigned to the receiving client along with
## a list of peer IDs currently assigned to other connected clients.
##
## This allows a newly connected client to establish its network identity and
## become aware of the other clients currently connected to the server.


## Runtime
# Network peer ID assigned to the client receiving this packet.
var peer_id : int

# Network peer IDs of other clients currently connected to the server.
var remote_peer_ids : Array[int]


## Public Interface
# Create a peer ID assignment packet.
#
# The packet contains the peer ID assigned to the receiving client and a list
# of peer IDs currently known by the server.
#
# Reliable delivery is used because the receiving client needs this
# information to establish its network identity correctly.
static func create(p_peer_id : int, p_remote_peer_ids : Array[int]) -> PeerIDAssignmentPacket:
	var info : PeerIDAssignmentPacket = PeerIDAssignmentPacket.new()
	
	info.packet_type = PACKET_TYPE.PEER_ID_ASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.peer_id = p_peer_id
	info.remote_peer_ids = p_remote_peer_ids
	
	return info


# Create a peer ID assignment packet from an encoded packet payload.
#
# The supplied byte array is decoded into the packet's runtime properties.
static func create_from_data(data : PackedByteArray) -> PeerIDAssignmentPacket:
	var info : PeerIDAssignmentPacket = PeerIDAssignmentPacket.new()
	
	info.decode(data)
	
	return info


# Encode the peer ID assignment packet into a byte array.
#
# Packet layout:
#
# Byte 0       : Packet type
# Byte 1       : Assigned peer ID
# Bytes 2+     : IDs of other connected peers
#
# Each ID occupies a single byte, matching the peer ID range used by the
# network handler.
func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	
	# Allocate one byte for the assigned peer ID and one byte for each remote
	# peer ID.
	data.resize(2 + remote_peer_ids.size())
	
	# Write the assigned peer ID immediately after the packet type.
	data.encode_u8(1, peer_id)
	
	# Write each remote peer ID into the remaining bytes.
	for i in remote_peer_ids.size():
		data.encode_u8(2 + i, remote_peer_ids[i])
	
	return data


# Decode an encoded peer ID assignment packet.
#
# The packet type is decoded by the parent class before the assigned peer ID
# and remote peer IDs are read from the packet payload.
func decode(data : PackedByteArray) -> void:
	super.decode(data)
	
	# Read the peer ID assigned to the receiving client.
	peer_id = data.decode_u8(1)
	
	# Read every remaining byte as the ID of another connected peer.
	for i in range(2, data.size()):
		remote_peer_ids.append(data.decode_u8(i))
