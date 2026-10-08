class_name EntityPacket
extends Packet

## Base class for packets addressed to a specific network entity.
##
## Provides the network entity ID shared by all packets that contain data
## relating to a specific entity. The entity ID identifies the entity itself,
## regardless of which component or system the packet data relates to.


## Config
# Index of the byte which stores entity ID.
const entity_id_byte : int = 1

# Minimum valid entity ID. Zero is reserved as invalid or unassigned.
const min_entity_id : int = 1

# Maximum valid entity ID representable by an unsigned 16-bit integer.
const max_entity_id : int = 65535


## Runtime
# Application-assigned ID of the entity this packet relates to.
var entity_id : int = 0


## Process
# Initialise the common properties shared by all entity packets.
#
# Calls the parent constructor to initialise the common Packet properties.
func _init(type : PacketType = PacketType.EMPTY, target_entity_id : int = 0) -> void:
	super._init(type)
	
	if target_entity_id != 0:
		_set_entity_id(target_entity_id)


## Public Interface
# Encode the entity ID, along with common data into a byte array.
func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.encode_u16(entity_id_byte, entity_id)
	
	return data

# Decode the common entity packet data.
func decode(data : PackedByteArray) -> bool:
	if not super.decode(data):
		return false

	return _set_entity_id(data.decode_u16(entity_id_byte))


## Private Methods
# Assign and validate an entity ID.
func _set_entity_id(new_entity_id : int) -> bool:
	if new_entity_id < min_entity_id or new_entity_id > max_entity_id:
		push_error("Entity packet '%s' received an invalid entity ID of '%s'. Value must be between %s and %s." % [self, new_entity_id, min_entity_id, max_entity_id])
		
		return false
	
	entity_id = new_entity_id
	
	return true
