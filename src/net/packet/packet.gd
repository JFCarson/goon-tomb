class_name Packet
extends RefCounted

## Base class for network packets.
##
## Provides the common packet type and transmission settings shared by all
## packet types, as well as methods for encoding and decoding packet data
## through Godot's MultiplayerAPI.


## Packet Types
# Identifies the type of data contained within a packet.
#
# The numeric value is written into the first byte of every packet so that the
# receiving application can determine which packet class should decode it.
enum PacketType {
	EMPTY,
	ENTITY_POSITION
}


## Config
# Index of the byte which stores packet type data.
const type_byte : int = 0


## Runtime
# Size in bytes of the packet.
var packet_size : int = 1

# Stores the type of packet represented by this instance. Defaults to an
# empty packet, and can be redeclared in the init of derived packet classes.
var packet_type : PacketType = PacketType.EMPTY

# Stores the packet transfer mode used when transmitting this packet.
var transfer_mode : MultiplayerPeer.TransferMode


## Process
# Initialise the common properties shared by all packet types.
#
# Derived packet classes can call this method through super._init() to
# initialise the properties introduced by this class.
func _init(type : PacketType = PacketType.EMPTY) -> void:
	packet_type = type


## Public Interface
# Encode the packet's common data into a byte array.
#
# Derived packet classes can extend the returned byte array with their own
# packet-specific data.
func encode() -> PackedByteArray:
	var data : PackedByteArray
	
	data.resize(packet_size)
	data.encode_u8(type_byte, int(packet_type))
	
	return data


# Decode the packet's common data from an encoded packet payload.
#
# Derived packet classes can call this method before decoding their own
# packet-specific data.
func decode(data : PackedByteArray) -> bool:
	if data.size() < packet_size:
		push_error("Packet data is too small to decode.")
		return false

	packet_type = data.decode_u8(type_byte) as PacketType

	return true
