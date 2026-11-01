class_name MultiplayerPeerCharacter
extends CharacterBody3D

## Controller responsible for interpolating replicated movement.
@onready var remote_controller : RemoteCharacterController = $RemoteCharacterController


## Handles incoming network packets for this character.
func handle_network_packet(packet : DecodedPacket) -> void:
	if packet == null:
		return

	match packet.packet_type_id:
		PacketEnums.Type.PLAYER_MOVEMENT:
			_handle_movement_packet(packet)


## Applies incoming movement and relays it to other clients when running
## on the server.
func _handle_movement_packet(packet : DecodedPacket) -> void:
	remote_controller.apply_replicated_transform(
		packet.values.get(PacketEnums.FieldName.POSITION, global_position),
		packet.values.get(PacketEnums.FieldName.ROTATION, global_rotation.y)
	)
	
	self.velocity = packet.values.get(PacketEnums.FieldName.VELOCITY,Vector3.ZERO)
	
	if NetworkHandler.is_server:
		NetworkGlobals.broadcast_packet(PacketEnums.Type.PLAYER_MOVEMENT, packet.values, packet.entity_id, packet.sender_peer_id)
