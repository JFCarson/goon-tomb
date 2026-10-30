class_name PacketEnums
extends RefCounted

## Stores enum values for network packets.


## Maintained list of types of which a packet can be. These can be used to
## determine behaviour upon recieving a packet.
##
## This enum should not exceed 256 values, including EMPTY.
enum Type {
	EMPTY = 0,
	TEST_PACKET = 1,
	CLIENT_HANDSHAKE = 2,
	SERVER_HANDSHAKE = 3,
	
	# Entity Types
	PLAYER_SPAWN = 49,
	ENTITY_SPAWN = 50,
	ENTITY_DESPAWN = 51,
	PLAYER_MOVEMENT = 52,
}


## Packet types that manage entity creation or removal.
const entity_lifecycle_types : Array[Type] = [
	Type.PLAYER_SPAWN,
	Type.ENTITY_SPAWN,
	Type.ENTITY_DESPAWN
]


## Value to determine whether a packet's sender should be restricted to either
## server or client, or if both are allowed to send it.
enum Direction {
	AGNOSTIC = 0,
	CLIENT_TO_SERVER = 1,
	SERVER_TO_CLIENT = 2
}


## Value to provide context into the direction of a packet.
enum DirectionContext {
	SEND_TO_SERVER,
	SEND_TO_PEER,
	BROADCAST,
	RECEIVE_FROM_CLIENT,
	RECEIVE_FROM_SERVER
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
	PLAYER_PEER_ID = 1,
	MESSAGE_ID = 2,
	TEST_VALUE = 3,
	ACCEPTED = 4,
	PROTOCOL_VERSION = 5,
	
	# Entity Fields
	ENTITY_TYPE = 49,
	ACTION_FLAGS = 50,
	INPUT_SEQUENCE = 51,
	MOVEMENT_DIRECTION = 60,
	VELOCITY = 61,
	POSITION = 62,
	ROTATION = 63
}
