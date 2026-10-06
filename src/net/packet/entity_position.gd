class_name EntityPositionPacket
extends PacketInfo

## Packet containing the network position of an entity.
##
## Stores the entity's application-assigned ID and its world-space position.
## The packet uses an unsequenced ENet flag because entity positions represent
## frequently updated state where older updates may become irrelevant before
## they are received.


## Runtime
# Application-assigned ID of the entity whose position is being transmitted.
var entity_id : int

# World-space position of the entity.
var position : Vector3


## Public Interface
# Create an entity position packet from an entity ID and world-space position.
#
# The packet is configured to use ENet's unsequenced delivery mode because
# position updates are transient state. If several updates are sent in quick
# succession, receiving an older update after a newer one is not useful.
static func create(p_entity_id : int, p_position : Vector3) -> EntityPositionPacket:
	var info : EntityPositionPacket = EntityPositionPacket.new()
	
	info.packet_type = PACKET_TYPE.ENTITY_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.entity_id = p_entity_id
	info.position = p_position
	
	return info


# Create an entity position packet from an encoded packet payload.
#
# The supplied byte array is decoded into the packet's runtime properties.
static func create_from_data(data : PackedByteArray) -> EntityPositionPacket:
	var info : EntityPositionPacket = EntityPositionPacket.new()
	
	info.decode(data)
	
	return info


# Encode the entity position packet into a byte array.
#
# Packet layout:
#
# Byte 0      : Packet type
# Byte 1      : Entity ID
# Bytes 2-5   : Position X
# Bytes 6-9   : Position Y
# Bytes 10-13 : Position Z
#
# Each Vector3 component is stored as a 32-bit floating-point value, requiring
# four bytes.
func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	
	# Allocate space for the packet header, entity ID, and three position
	# components.
	data.resize(14)
	
	# Write the entity ID immediately after the packet type.
	data.encode_u8(1, entity_id)
	
	# Write each position component as a 32-bit floating-point value.
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, position.z)
	
	return data


# Decode an encoded entity position packet.
#
# The packet type is decoded by the parent class before the entity ID and
# position data are read from the packet payload.
func decode(data : PackedByteArray) -> void:
	super.decode(data)
	
	entity_id = data.decode_u8(1)
	position = Vector3(data.decode_float(2), data.decode_float(6), data.decode_float(10))
