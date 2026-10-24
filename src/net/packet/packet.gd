@tool
class_name Packet
extends Resource

## Defines the wire format for a network packet.


# Config
## Number of bytes used to identify the packet type in the header.
const type_byte_size : int = 1

## Number of bytes used to identify the entity associated with an entity packet.
const entity_id_byte_size : int = 2

## Maximum number of fields permitted in a single packet definition.
const max_field_count : int = 32

## Maximum permitted packet size, including the header and payload, in bytes.
const max_packet_size : int = 1024

## Unique identifier for this packet type, transmitted in the packet header.
@export var packet_type_id : PacketEnums.Type = PacketEnums.Type.EMPTY

## Determines the header structure and whether the packet is associated with
## a specific entity.
@export var category : PacketEnums.Category = PacketEnums.Category.GLOBAL

## ENet transfer mode used when sending this packet type.
@export var transfer_mode : MultiplayerPeer.TransferMode = MultiplayerPeer.TRANSFER_MODE_RELIABLE

## Ordered list of fields that make up the packet payload.
@export var fields : Array[PacketField] = []


# Public Interface
## Returns the size of the packet header in bytes, including the packet type ID
## and, for entity packets, the entity ID.
func get_header_size() -> int:
	match category:
		PacketEnums.Category.GLOBAL:
			return type_byte_size
			
		PacketEnums.Category.ENTITY:
			return type_byte_size + entity_id_byte_size
			
	return 0  # A zero size indicates an unsupported category.


## Calculates the combined size of all payload fields in bytes.
func get_payload_size() -> int:
	var size : int = 0
	
	for field : PacketField in fields:
		# Ignore null entries here; validation reports them separately.
		if field == null:
			continue
			
		size += field.get_byte_size()
		
	return size


## Returns the total packet size: header plus payload, in bytes.
func get_packet_size() -> int:
	return get_header_size() + get_payload_size()


## Checks that this definition can be registered and used by the PacketProcessor.
func is_valid_definition() -> bool:
	# Ensure the packet type is declared and is not the reserved EMPTY value.
	if not PacketEnums.Type.values().has(packet_type_id) or packet_type_id == PacketEnums.Type.EMPTY:
		push_error("Packet definition has an invalid packet type.")
		return false
		
	# Ensure the packet type can be represented by the unsigned 8-bit header.
	if packet_type_id < 0 or packet_type_id > 255:
		push_error("Packet definition ID must fit within an unsigned 8-bit value.")
		return false
		
	# A valid category must produce a recognised header size.
	if get_header_size() == 0:
		push_error("Packet definition has an invalid category.")
		return false
		
	# Ensure the transfer mode is supported by Godot's multiplayer API.
	if not [
		MultiplayerPeer.TRANSFER_MODE_RELIABLE,
		MultiplayerPeer.TRANSFER_MODE_UNRELIABLE,
		MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
	].has(transfer_mode):
		push_error("Packet definition has an invalid transfer mode.")
		return false
		
	# Prevent packet definitions from containing excessive numbers of fields.
	if fields.size() > max_field_count:
		push_error("Packet definition exceeds the maximum field count of %d." % max_field_count)
		return false
		
	# Track field names to ensure each payload field can be uniquely identified.
	var field_names : Dictionary = {}
	
	for field : PacketField in fields:
		# Every entry must reference a valid field definition.
		if field == null:
			push_error("Packet definition contains a null field.")
			return false
			
		# Every field name must be a declared enum value.
		if not PacketEnums.FieldName.values().has(field.field_name):
			push_error("Packet definition contains an invalid field name.")
			return false
			
		# The undefined field name is reserved and cannot be used.
		if field.field_name == PacketEnums.FieldName.UNDEFINED:
			push_error("Packet definition contains an undefined field.")
			return false
			
		# Every field type must be a declared enum value.
		if not PacketEnums.FieldType.values().has(field.field_type):
			push_error("Packet field '%s' has an invalid field type." % field.field_name)
			return false
			
		# Duplicate names would make payload values ambiguous.
		if field_names.has(field.field_name):
			push_error("Packet definition contains duplicate field '%s'." % field.field_name)
			return false
			
		# Every supported field type must have a known, positive byte size.
		if field.get_byte_size() <= 0:
			push_error("Packet field '%s' has an unsupported type." % field.field_name)
			return false
			
		# Record this name so subsequent fields can be checked against it.
		field_names[field.field_name] = true
		
	# Reject definitions whose header and payload exceed the configured limit.
	if get_packet_size() > max_packet_size:
		push_error("Packet definition exceeds the maximum packet size of %d bytes." % max_packet_size)
		return false
		
	return true
