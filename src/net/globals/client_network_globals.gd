extends Node


signal handle_local_id_assignment(local_id : int)
signal handle_remote_id_assignment(remote_id : int)

signal handle_entity_position(entity_position : EntityPositionPacket)


var id : int = -1

var remote_ids : Array[int]


func _ready() -> void:
	NetHandler.on_client_packet.connect(_on_client_packet)


func _on_client_packet(data : PackedByteArray) -> void:
	var packet_type : int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			_manage_ids(IDAssignmentPacket.create_from_data(data))
			
		PacketInfo.PACKET_TYPE.ENTITY_POSITION:
			handle_entity_position.emit(EntityPositionPacket.create_from_data(data))
			
		_:
			push_error("Packet type with index ", data[0], "unhandled.")


func _manage_ids(id_assignment : IDAssignmentPacket) -> void:
	if id == -1:
		id = id_assignment.id
		handle_local_id_assignment.emit(id)
		
		remote_ids = id_assignment.remoted_ids
		
		for remote_id in remote_ids:
			if remote_id == id:
				continue
			
			handle_remote_id_assignment.emit(remote_id)
	else:
		remote_ids.append(id_assignment.id)
		handle_remote_id_assignment.emit(id_assignment.id)
