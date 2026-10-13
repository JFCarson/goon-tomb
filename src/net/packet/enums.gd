class_name PacketEnums
extends RefCounted

## Stores enum values for network packets.


# Maintained list of types of which a packet can be. These can be used to
# determine behaviour upon recieving a packet.
#
# This enum should not exceed 256 values, including EMPTY.
enum Type {
	EMPTY,
	ENTITY_POSITION
}


# Maintained list of field types that are available for en/decoding.
#
# Any additions or deletions to this list will require updates in code.
enum FieldType {
	UINT8,
	UINT16,
	INT32,
	FLOAT32,
	VECTOR3
}


# Value to determine whether a packet is associated with an entity.
enum Category {
	GLOBAL,
	ENTITY
}
