extends Node


signal handle_entity_position(peer_id : int, entity_postion : EntityPositionPacket)


var peer_ids : Array[int]


func _ready() -> void:
	NetHandler.on_peer_connected.connect(_on_peer_connected)
	NetHandler.on_peer_disconnected.connect(_on_peer_disconnected)
	NetHandler.on_server_packet.connect(_on_server_packet)


func _on_peer_connected(peer_id : int) -> void:
	peer_ids.append(peer_id)
	
	IDAssignmentPacket.create(peer_id, peer_ids).broadcast(NetHandler.connection)


func _on_peer_disconnected(peer_id : int) -> void:
	peer_ids.erase(peer_id)
	
	# NOTE: NEED TO CREATE AN ID UNASSIGNMENT PACKET.


func _on_server_packet(peer_id : int, data : PackedByteArray) -> void:
	var packet_type : int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ENTITY_POSITION:
			handle_entity_position.emit(peer_id, EntityPositionPacket.create_from_data(data))
		
		_:
			push_error("Packet type with index ", data[0], "unhandled.")
