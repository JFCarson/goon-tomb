@tool
class_name Packet
extends Resource

## Defines the wire format for a network packet.


## Config
# Number of bytes used to identify the packet type in the header.
const type_byte_size : int = 1

# Number of bytes used to identify the entity associated with an entity packet.
const entity_id_byte_size : int = 2

# Unique identifier for this packet type, transmitted in the packet header.
@export var packet_type_id : PacketEnums.Type = PacketEnums.Type.EMPTY

# Determines the header structure and whether the packet is associated with
# a specific entity.
@export var category : PacketEnums.Category = PacketEnums.Category.GLOBAL

# ENet transfer mode used when sending this packet type.
@export var transfer_mode : MultiplayerPeer.TransferMode = MultiplayerPeer.TRANSFER_MODE_RELIABLE

# Ordered list of fields that make up the packet payload.
@export var fields : Array[PacketField] = []


## Public Interface
# Returns the size of the packet header in bytes, including the packet type ID
# and, for entity packets, the entity ID.
func get_header_size() -> int:
	match category:
		PacketEnums.Category.GLOBAL:
			return type_byte_size
		
		PacketEnums.Category.ENTITY:
			return type_byte_size + entity_id_byte_size

	# A zero size indicates an unsupported category.
	return 0


# Calculates the combined size of all payload fields in bytes.
func get_payload_size() -> int:
	var size : int = 0

	for field : PacketField in fields:
		# Ignore null entries here; validation reports them separately.
		if field == null:
			continue

		size += field.get_byte_size()

	return size


# Returns the total packet size: header plus payload, in bytes.
func get_packet_size() -> int:
	return get_header_size() + get_payload_size()


# Checks that this definition can be registered and used by the PacketProcessor.
func is_valid_definition() -> bool:
	# Ensure the packet type is declared and is not the reserved EMPTY value.
	if not PacketEnums.Type.values().has(packet_type_id) or packet_type_id == PacketEnums.Type.EMPTY:
		push_error("Packet definition has an invalid packet type.")
		return false

	# A valid category must produce a recognised header size.
	if get_header_size() == 0:
		push_error("Packet definition has an invalid category.")
		return false

	# Track field names to ensure each payload field can be uniquely identified.
	var field_names : Dictionary = {}

	for field : PacketField in fields:
		# Every entry must reference a valid field definition.
		if field == null:
			push_error("Packet definition contains a null field.")
			return false

		# Each field needs a name so its value can be supplied and retrieved
		# through the payload dictionary.
		if field.field_name.is_empty():
			push_error("Packet definition contains a field with no name.")
			return false

		# Duplicate names would make payload values ambiguous.
		if field_names.has(field.field_name):
			push_error(
				"Packet definition contains duplicate field '%s'."
				% field.field_name
			)
			return false

		# Every supported field type must have a known, positive byte size.
		if field.get_byte_size() <= 0:
			push_error(
				"Packet field '%s' has an unsupported type."
				% field.field_name
			)
			return false

		# Record this name so subsequent fields can be checked against it.
		field_names[field.field_name] = true

	return true
