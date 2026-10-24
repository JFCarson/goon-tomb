class_name DecodedPacket
extends RefCounted

## Contains a decoded network packet and its associated metadata.
##
## Packet metadata is stored as typed properties. Payload values remain
## keyed by PacketEnums.FieldName to preserve the existing packet schema.


# Packet Metadata
## Type identifier of the decoded packet.
var packet_type_id : PacketEnums.Type

## Category of the decoded packet.
var category : PacketEnums.Category

## Entity associated with the packet, or zero for global packets.
var entity_id : int = 0

## Transfer mode configured for this packet type.
##
## This describes the local packet definition; it does not prove
## the actual transport mode used for delivery.
var transfer_mode : MultiplayerPeer.TransferMode

# Sender Context
## Peer ID supplied by the transport layer, never by the packet payload.
var sender_peer_id : int = 0

# Payload
## Decoded payload values keyed by PacketEnums.FieldName.
var values : Dictionary = {}
