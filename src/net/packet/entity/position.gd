class_name EntityPositionPacket
extends EntityPacket

## Packet containing the network position of an entity.
##
## Stores the entity's application-assigned ID and its world-space position.
## The packet uses unreliable ordered delivery because entity positions
## represent frequently updated state where older updates may become irrelevant
## before they are received.


## Config
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
func _init(p_entity_id : int = 0, p_position : Vector3 = Vector3.ZERO) -> void:
	packet_size = 15

	super._init(PacketType.ENTITY_POSITION, p_entity_id)

	transfer_mode = MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
	position = p_position


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
func decode(data : PackedByteArray) -> bool:
	if data.size() != packet_size:
		push_error("Entity position packet has an invalid size.")
		return false

	if not super.decode(data):
		return false

	position = Vector3(
		data.decode_float(x_start_byte),
		data.decode_float(y_start_byte),
		data.decode_float(z_start_byte)
	)

	return true
