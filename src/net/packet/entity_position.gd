class_name EntityPositionPacket
extends PacketInfo


var id : int

var position : Vector3


static func create(id : int, position : Vector3) -> EntityPositionPacket:
	var info : EntityPositionPacket = EntityPositionPacket.new()
	
	info.packet_type = PACKET_TYPE.ENTITY_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = id
	info.position = position
	
	return info


static func create_from_data(data : PackedByteArray) -> EntityPositionPacket:
	var info : EntityPositionPacket = EntityPositionPacket.new()
	
	info.decode(data)
	
	return info


func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	
	data.resize(14)
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, position.x)
	
	return data


func decode(data : PackedByteArray) -> void:
	super.decode(data)
	
	id = data.decode_double(1)
	position = Vector3(data.decode_float(2), data.decode_float(6), data.decode_float(10))
