class_name DecodedPacketField
extends RefCounted

## Result of decoding a single packet field.
##
## A successful result contains the decoded field value.
## A failed result indicates that the field could not be decoded.


# Runtime
## Whether the field was decoded successfully.
var success : bool = false

## Decoded field value, or null when decoding fails.
var value : Variant = null


# Public Interface
## Creates a successful decode result containing the supplied value.
static func succeeded(decoded_value : Variant) -> DecodedPacketField:
	var result : DecodedPacketField = DecodedPacketField.new()
	result.success = true
	result.value = decoded_value
	return result


## Creates a failed decode result.
static func failed() -> DecodedPacketField:
	return DecodedPacketField.new()
