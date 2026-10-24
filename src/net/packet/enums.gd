class_name PacketEnums
extends RefCounted

## Stores enum values for network packets.


## Maintained list of types of which a packet can be. These can be used to
## determine behaviour upon recieving a packet.
##
## This enum should not exceed 256 values, including EMPTY.
enum Type {
	EMPTY = 0,
	CLIENT_HANDSHAKE = 1,
	SERVER_HANDSHAKE = 2,
	ENTITY_POSITION = 3
}


## Value to determine whether a packet is associated with an entity.
enum Category {
	GLOBAL = 0,
	ENTITY = 1
}


## Maintained list of field types that are available for en/decoding.
##
## Any additions or deletions to this list will require updates in code.
enum FieldType {
	BOOL = 0,
	UINT8 = 1,
	UINT16 = 2,
	INT32 = 3,
	FLOAT32 = 4,
	VECTOR2 = 5,
	VECTOR3 = 6
}


## Maintained list of enumerated field names that can be used freely as
## identifiers for consistency when encoding or decoding packets.
enum FieldName {
	UNDEFINED = 0,
	ACCEPTED = 1,
	PROTOCOL_VERSION = 2,
	POSITION = 3	
}
