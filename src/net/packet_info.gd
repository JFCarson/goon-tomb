class_name PacketInfo

## Base class for network packets.
##
## Provides the common packet type and transmission settings shared by all
## packet types, as well as methods for encoding, decoding, and transmitting
## packet data through ENet.


## Config
# Identifies the type of data contained within a packet.
#
# The numeric value is written into the first byte of every packet so that the
# receiving application can determine which packet class should decode it.
enum PACKET_TYPE {
	PEER_ID_ASSIGNMENT,
	ENTITY_POSITION
}


## Runtime
# Stores the type of packet represented by this instance.
var packet_type : PACKET_TYPE

# Stores the ENet packet flags used when transmitting this packet.
#
# These flags determine how ENet handles the packet, such as whether it should
# be delivered reliably or whether ordering should be ignored.
var flag : int


## Public Interface
# Encode the packet header into a byte array.
#
# The base packet format consists of a single byte containing the packet type.
# Child packet classes extend this data with their own packet-specific fields.
func encode() -> PackedByteArray:
	var data : PackedByteArray
	
	# Allocate one byte for the packet type.
	data.resize(1)
	
	# Write the packet type into the first byte of the packet.
	data.encode_u8(0, packet_type)
	
	return data


# Decode the packet header from a byte array.
#
# Child packet classes call this function before decoding their own
# packet-specific data.
func decode(data : PackedByteArray) -> void:
	# Read the packet type from the first byte.
	packet_type = data.decode_u8(0) as PACKET_TYPE


# Send this packet directly to a specific ENet peer.
#
# The packet is encoded into its byte representation before being passed to
# ENet.
func send(target : ENetPacketPeer, channel : int = 0) -> void:
	target.send(channel, encode(), flag)


# Broadcast this packet to all connected peers through the server.
#
# The packet is encoded once and then sent to every connected peer by ENet.
func broadcast(server : ENetConnection, channel : int = 0) -> void:
	server.broadcast(channel, encode(), flag)
