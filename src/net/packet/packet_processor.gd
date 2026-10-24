class_name PacketProcessor
extends RefCounted

## Encodes and decodes packets using registered packet definitions.
##
## Maintains a registry of packet definitions and uses them to serialise
## and deserialise packet data. Handles the common packet header, including
## the entity ID for entity packets, while delegating payload fields to
## the appropriate field encoding and decoding methods.


# Runtime
## Stores registered packet definitions, indexed by their unique packet type ID.
var definitions : Dictionary[int, Packet] = {}


# Public Interface
## Registers a packet definition so it can be used to encode and decode packets.
##
## Rejects invalid definitions and prevents multiple definitions from using
## the same packet type ID.
func register_definition(definition : Packet) -> bool:
	if definition == null or not definition.is_valid_definition():
		return false
		
	if definitions.has(definition.packet_type_id):
		push_error("Packet type ID '%s' is already registered." % definition.packet_type_id)
		return false
		
	definitions[definition.packet_type_id] = definition
	return true


## Retrieves a registered packet definition using its packet type ID.
func get_definition(packet_type_id : int) -> Packet:
	return definitions.get(packet_type_id) as Packet


## Encodes a packet into a byte array using its registered definition.
func encode(packet_type_id : int, values : Dictionary, entity_id : int = 0) -> PackedByteArray:
	# Retrieve the definition that describes the packet's structure.
	var definition : Packet = get_definition(packet_type_id)
	
	if definition == null:
		push_error("Cannot encode an unregistered packet type.")
		return PackedByteArray()
		
	if not definition.is_valid_definition():
		push_error("Cannot encode packet: registered definition is no longer valid.")
		return PackedByteArray()
		
	if definition.packet_type_id != packet_type_id:
		push_error("Cannot encode packet: registered definition ID has changed.")
		return PackedByteArray()
		
	if values.size() != definition.fields.size():
		push_error("Packet payload contains an incorrect number of fields.")
		return PackedByteArray()
		
	# Validate the entity ID against the packet category.
	if definition.category == PacketEnums.Category.ENTITY:
		if entity_id < 1 or entity_id > 65535:
			push_error("Entity packet has an invalid entity ID.")
			return PackedByteArray()
	elif entity_id != 0:
		push_error("Global packet cannot have an entity ID.")
		return PackedByteArray()
			
	# Allocate enough space for the common header and all payload fields.
	var data : PackedByteArray
	data.resize(definition.get_packet_size())
	
	# Write the packet type ID into the first byte of the header.
	data.encode_u8(0, packet_type_id)
	
	# Begin writing immediately after the packet type ID.
	var offset : int = Packet.type_byte_size
	
	# Encode the entity ID if iterating over an entity packet.
	if definition.category == PacketEnums.Category.ENTITY:
		data.encode_u16(offset, entity_id)
		offset += Packet.entity_id_byte_size
		
	# Encode each payload field in the order specified by the definition.
	for field : PacketField in definition.fields:
		if not values.has(field.field_name):
			push_error("Missing packet field '%s'." % field.field_name)
			return PackedByteArray()
			
		# Encode the field at the current byte offset using its configured type.
		if not _encode_field(data, offset, field, values[field.field_name]):
			return PackedByteArray()
			
		# Advance past the encoded field to the beginning of the next field.
		offset += field.get_byte_size()
		
	return data


## Decodes a byte array into a typed packet object.
##
## Returns a DecodedPacket on success, or null if the packet is invalid.
func decode(data : PackedByteArray) -> DecodedPacket:
	# Reject empty packets before reading the packet type.
	if data.is_empty():
		push_error("Received an empty packet.")
		return null
		
	# Retrieve the definition that describes the packet structure.
	var packet_type_id : int = data.decode_u8(0)
	var definition : Packet = get_definition(packet_type_id)
	if definition == null:
		push_error("Received an unregistered packet type.")
		return null
		
	if not definition.is_valid_definition():
		push_error("Cannot decode packet: registered definition is no longer valid.")
		return null

	if definition.packet_type_id != packet_type_id:
		push_error("Cannot decode packet: registered definition ID has changed.")
		return null
		
	# Require the received data to match the exact expected packet size.
	if data.size() != definition.get_packet_size():
		push_error("Received packet with an invalid size.")
		return null
		
	# Read the entity ID when the packet targets a specific entity.
	var entity_id : int = 0
	var offset : int = Packet.type_byte_size
	if definition.category == PacketEnums.Category.ENTITY:
		entity_id = data.decode_u16(offset)
		offset += Packet.entity_id_byte_size
		
		if entity_id == 0:
			push_error("Received an entity packet with an invalid entity ID.")
			return null
			
	# Decode each payload field in the order defined by the packet.
	var values : Dictionary = {}
	for field : PacketField in definition.fields:
		var result : DecodedPacketField = _decode_field(data, offset, field)
		if not result.success:
			return null

		values[field.field_name] = result.value
		offset += field.get_byte_size()
		
	# Populate the typed packet object with the decoded data.
	var packet : DecodedPacket = DecodedPacket.new()
	packet.packet_type_id = packet_type_id as PacketEnums.Type
	packet.category = definition.category
	packet.entity_id = entity_id
	packet.transfer_mode = definition.transfer_mode
	packet.values = values
	
	return packet


# Private Methods
## Encodes a single payload field according to its configured wire type.
func _encode_field(data : PackedByteArray, offset : int, field : PacketField, value : Variant) -> bool:
	match field.field_type:
		# Encode a boolean value.
		PacketEnums.FieldType.BOOL:
			if typeof(value) != TYPE_BOOL:
				return _invalid_field_value(field)
			data.encode_u8(offset, 1 if value else 0)
		
		# Encode an unsigned 8-bit integer.
		PacketEnums.FieldType.UINT8:
			if typeof(value) != TYPE_INT or value < 0 or value > 255:
				return _invalid_field_value(field)
			data.encode_u8(offset, value)
			
		# Encode an unsigned 16-bit integer.
		PacketEnums.FieldType.UINT16:
			if typeof(value) != TYPE_INT or value < 0 or value > 65535:
				return _invalid_field_value(field)
			data.encode_u16(offset, value)
			
		# Encode a signed 32-bit integer.
		PacketEnums.FieldType.INT32:
			if typeof(value) != TYPE_INT or value < -2147483648 or value > 2147483647:
				return _invalid_field_value(field)
			data.encode_s32(offset, value)
			
		# Encode a finite 32-bit floating-point number.
		PacketEnums.FieldType.FLOAT32:
			if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
				return _invalid_field_value(field)
			if not is_finite(float(value)):
				return _invalid_field_value(field)
			data.encode_float(offset, float(value))
		
		# Encode a Vector2 with finite components.
		PacketEnums.FieldType.VECTOR2:
			if typeof(value) != TYPE_VECTOR2:
				return _invalid_field_value(field)
			if not is_finite(value.x) or not is_finite(value.y):
				return _invalid_field_value(field)
			data.encode_float(offset, value.x)
			data.encode_float(offset + 4, value.y)
		
		# Encode a Vector3 with finite components.
		PacketEnums.FieldType.VECTOR3:
			if typeof(value) != TYPE_VECTOR3:
				return _invalid_field_value(field)
			if not is_finite(value.x) or not is_finite(value.y) or not is_finite(value.z):
				return _invalid_field_value(field)
			data.encode_float(offset, value.x)
			data.encode_float(offset + 4, value.y)
			data.encode_float(offset + 8, value.z)
			
		# Reject any field type that does not have an encoding implementation.
		_:
			return _invalid_field_value(field)
			
	return true


## Decodes a single payload field according to its configured wire type.
func _decode_field(data : PackedByteArray, offset : int, field : PacketField) -> DecodedPacketField:
	var value : Variant
	
	match field.field_type:
		# Decode a boolean value, rejecting bytes other than 0 or 1.
		PacketEnums.FieldType.BOOL:
			var bool_byte : int = data.decode_u8(offset)
			if bool_byte > 1:
				push_error("Invalid boolean value for packet field '%s'." % field.field_name)
				return DecodedPacketField.failed()
			value = bool_byte == 1
			
		# Decode an unsigned 8-bit integer.
		PacketEnums.FieldType.UINT8:
			value = data.decode_u8(offset)
		
		# Decode an unsigned 16-bit integer.
		PacketEnums.FieldType.UINT16:
			value = data.decode_u16(offset)
		
		# Decode a signed 32-bit integer.
		PacketEnums.FieldType.INT32:
			value = data.decode_s32(offset)
		
		# Decode a finite 32-bit floating-point number.
		PacketEnums.FieldType.FLOAT32:
			value = data.decode_float(offset)
			if not is_finite(value):
				push_error("Non-finite float in packet field '%s'." % field.field_name)
				return DecodedPacketField.failed()
				
		# Decode two consecutive finite floats into a Vector2.
		PacketEnums.FieldType.VECTOR2:
			value = Vector2(
				data.decode_float(offset),
				data.decode_float(offset + 4)
			)
			if not is_finite(value.x) or not is_finite(value.y):
				push_error("Non-finite vector component in packet field '%s'." % field.field_name)
				return DecodedPacketField.failed()
		
		# Decode three consecutive finite floats into a Vector3.
		PacketEnums.FieldType.VECTOR3:
			value = Vector3(
				data.decode_float(offset),
				data.decode_float(offset + 4),
				data.decode_float(offset + 8)
			)
			if not is_finite(value.x) or not is_finite(value.y) or not is_finite(value.z):
				push_error("Non-finite vector component in packet field '%s'." % field.field_name)
				return DecodedPacketField.failed()
		
		# Reject any field type that does not have a decoding implementation.
		_:
			push_error("Unsupported packet field type.")
			return DecodedPacketField.failed()
			
	return DecodedPacketField.succeeded(value)



## Reports a field value that cannot be represented by its configured wire type.
func _invalid_field_value(field : PacketField) -> bool:
	push_error("Invalid value for packet field '%s'." % field.field_name)
	return false
