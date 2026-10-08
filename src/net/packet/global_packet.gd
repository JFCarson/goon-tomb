class_name GlobalPacket
extends Packet

## Base class for packets that are not associated with a specific network
## entity.


## Process
# Initialise the common properties shared by all global packets.
#
# Calls the parent constructor to initialise the common Packet properties.
func _init(type : PacketType = PacketType.EMPTY) -> void:
	super._init(type)
