class_name EntityNetworkingController
extends EntityController

## Handles networking for the entity.


# Public Interface
## Sends the player's current movement state to the server or other clients.
func send_movement_state() -> void:
	var entity_id : int = NetworkPlayerManager.get_peer_entity_id(NetworkHandler.server_id if NetworkHandler.is_server else entity.multiplayer.get_unique_id())
	if entity_id == 0:
		return
		
	var movement_state : Dictionary = {
		PacketEnums.FieldName.POSITION: entity.global_position,
		PacketEnums.FieldName.ROTATION: entity.global_rotation.y,
		PacketEnums.FieldName.VELOCITY: entity.velocity
	}
	
	if NetworkHandler.is_server:
		NetworkGlobals.broadcast_packet(PacketEnums.Type.PLAYER_MOVEMENT, movement_state, entity_id)
	else:
		NetworkGlobals.send_packet_to_server(PacketEnums.Type.PLAYER_MOVEMENT, movement_state, entity_id)
