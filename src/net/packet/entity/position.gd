class_name EntityPositionPacket
extends EntityPacket

## Packet containing the network position of an entity.
##
## Stores the entity's application-assigned ID and its world-space position.
## The packet uses unreliable ordered delivery because entity positions
## represent frequently updated state where older updates may become irrelevant
## before they are received.


## Config
# Internal reference to how many bytes should be in the packet.
const _packet_size : int = 15

# Index of the starting byte position for the Vector3 x value.
const x_start_byte : int = 3

# Index of the starting byte position for the Vector3 y value.
const y_start_byte : int = 7

# Index of the starting byte position for the Vector3 z value.
const z_start_byte : int = 11


## Runtime
# World-space position of the entity.
var position : Vector3


## Process
# Initialise the entity position packet.
func _init(target_entity_id : int = 0, entity_position : Vector3 = Vector3.ZERO) -> void:
	packet_size = _packet_size
	
	super._init(PacketType.ENTITY_POSITION, target_entity_id)
	
	transfer_mode = MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
	position = entity_position


## Public Interface
# Encode the entity position packet into a byte array.
func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	
	# Write each position component as a 32-bit floating-point value.
	data.encode_float(x_start_byte, position.x)
	data.encode_float(y_start_byte, position.y)
	data.encode_float(z_start_byte, position.z)
	
	return data


# Decode the entity position packet.
func decode(data : PackedByteArray) -> void:
	super.decode(data)
	
	position = Vector3(
		data.decode_float(x_start_byte),
		data.decode_float(y_start_byte),
		data.decode_float(z_start_byte)
	)
