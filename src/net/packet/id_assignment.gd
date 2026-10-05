class_name IDAssignmentPacket
extends PacketInfo


var id : int

var remoted_ids : Array[int]


static func create(id : int, remote_ids : Array[int]) -> IDAssignmentPacket:
	var info : IDAssignmentPacket = IDAssignmentPacket.new()
	
	info.packet_type = PACKET_TYPE.ID_ASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.remoted_ids = remote_ids
	
	return info


static func create_from_data(data : PackedByteArray) -> IDAssignmentPacket:
	var info : IDAssignmentPacket = IDAssignmentPacket.new()
	
	info.decode(data)
	
	return info


func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	
	data.resize(2 + remoted_ids.size())
	data.encode_u8(1, id)
	
	for i in remoted_ids.size():
		data.encode_u8(2 + i, remoted_ids[i])
	
	return data


func decode(data : PackedByteArray) -> void:
	super.decode(data)
	
	for i in range(2, data.size()):
		remoted_ids.append(data.decode_u8(i))
