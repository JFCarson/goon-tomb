@tool
class_name PacketField
extends Resource

## Defines one field in a packet's payload.
## Each field has a name and a type that determines how its value
## is encoded into and decoded from the packet's byte array.


## Config
# Name used to identify this field in the packet's payload dictionary.
@export var field_name : StringName = &""

# Determines the field's data type and its representation in the packet.
@export var field_type : PacketEnums.FieldType = PacketEnums.FieldType.UINT8


## Public Interface
# Returns the number of bytes required to represent this field's value.
# The result is used to calculate packet sizes and advance byte offsets
# during encoding and decoding.
func get_byte_size() -> int:
	match field_type:
		# Unsigned 8-bit integer: one byte.
		PacketEnums.FieldType.UINT8:
			return 1

		# Unsigned 16-bit integer: two bytes.
		PacketEnums.FieldType.UINT16:
			return 2

		# Signed 32-bit integer and 32-bit float: four bytes each.
		PacketEnums.FieldType.INT32, PacketEnums.FieldType.FLOAT32:
			return 4

		# Vector3: three 32-bit floats (x, y, and z), totalling twelve bytes.
		PacketEnums.FieldType.VECTOR3:
			return 12

	# A zero size indicates an unsupported field type.
	return 0
