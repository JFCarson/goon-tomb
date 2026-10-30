extends Node

## Coordinates player identity, ownership, spawning and despawning.


# Config
## Scene used for the locally controlled player.
const player_scene : PackedScene = preload("uid://dtd716hucmkrg")

## Scene used to represent players controlled by other peers.
const remote_player_scene : PackedScene = preload("uid://dkp1qp2dq15xk")

## World nodes that define valid player spawn transforms.
var spawn_points : Array[PlayerSpawnPoint] = []


# Runtime
## Index of the next spawn point to use.
var _next_spawn_point_index : int = 0

## Maps each owning peer ID to its player entity ID.
var peer_entity_ids : Dictionary[int, int] = {}

## Maps each player entity ID to its owning peer ID.
var entity_peer_ids : Dictionary[int, int] = {}

## Maps each player entity ID to its local scene representation.
var player_instances : Dictionary[int, Node3D] = {}


# Process
## Connects to networking lifecycle signals.
func _ready() -> void:
	if not NetworkSession.peer_became_ready.is_connected(_on_peer_became_ready):
		NetworkSession.peer_became_ready.connect(_on_peer_became_ready)
	if not NetworkHandler.peer_disconnected.is_connected(_on_peer_disconnected):
		NetworkHandler.peer_disconnected.connect(_on_peer_disconnected)
	if not NetworkHandler.networking_shutdown.is_connected(_on_networking_shutdown):
		NetworkHandler.networking_shutdown.connect(_on_networking_shutdown)
	if not NetworkGlobals.handle_client_packet.is_connected(_on_client_packet):
		NetworkGlobals.handle_client_packet.connect(_on_client_packet)


# Public Interface
## Creates the host player's local representation.
## Call this after starting the server.
func create_host_player() -> bool:
	if not NetworkHandler.is_server:
		push_warning("Cannot create host player: this instance is not the server.")
		return false
		
	return _spawn_player(NetworkHandler.server_id, player_scene) != 0


## Returns the entity ID assigned to a peer, or zero if absent.
func get_peer_entity_id(peer_id : int) -> int:
	return peer_entity_ids.get(peer_id, 0)


## Returns the owning peer ID for an entity, or zero if absent.
func get_entity_owner(entity_id : int) -> int:
	return entity_peer_ids.get(entity_id, 0)


## Returns the local scene instance for an entity, or null if absent.
func get_player_instance(entity_id : int) -> Node3D:
	var player : Node3D = player_instances.get(entity_id)
	
	if not is_instance_valid(player):
		player_instances.erase(entity_id)
		return null
		
	return player


## Registers a spawn point with the player network manager.
func register_spawn_point(spawn_point : PlayerSpawnPoint) -> void:
	if not is_instance_valid(spawn_point):
		return
		
	if spawn_points.has(spawn_point):
		return
		
	spawn_points.append(spawn_point)


## Unregisters a spawn point from the player network manager.
func unregister_spawn_point(spawn_point : PlayerSpawnPoint) -> void:
	spawn_points.erase(spawn_point)


# Private Methods
## Creates and registers a player's scene representation.
## Returns the entity ID, or zero if spawning fails.
func _spawn_player(peer_id : int, scene : PackedScene) -> int:
	if peer_entity_ids.has(peer_id):
		return peer_entity_ids[peer_id]
		
	var spawn_point : Node3D = _get_next_spawn_point()
	if spawn_point == null:
		return 0
		
	var entity_id : int = _allocate_entity_id()
	if entity_id == 0:
		return 0
		
	var player : Node3D = scene.instantiate() as Node3D
	if player == null:
		push_error("Cannot spawn player: scene root must extend Node3D.")
		return 0
		
	add_child(player)
	player.global_transform = spawn_point.global_transform
	
	if not NetworkEntityManager.register_entity(entity_id, player):
		player.queue_free()
		return 0
		
	peer_entity_ids[peer_id] = entity_id
	entity_peer_ids[entity_id] = peer_id
	player_instances[entity_id] = player
	
	return entity_id


## Allocates an unused entity ID.
func _allocate_entity_id() -> int:
	for entity_id : int in range(1, NetworkEntityManager.max_entity_id + 1):
		if entity_peer_ids.has(entity_id):
			continue
			
		if not NetworkEntityManager.has_entity(entity_id):
			return entity_id
			
	push_error("Cannot spawn player: no entity IDs are available.")
	return 0


## Returns the next valid spawn point in round-robin order.
func _get_next_spawn_point() -> Node3D:
	if spawn_points.is_empty():
		push_error("Cannot spawn player: no spawn points are configured.")
		return null
		
	for _attempt : int in range(spawn_points.size()):
		var index : int = _next_spawn_point_index % spawn_points.size()
		_next_spawn_point_index = index + 1
		
		var spawn_point : PlayerSpawnPoint = spawn_points[index]
		if is_instance_valid(spawn_point) and spawn_point.is_inside_tree():
			return spawn_point
			
	push_error("Cannot spawn player: no valid spawn points remain.")
	return null


## Sends a player's spawn information to a peer.
func _send_player_spawn(entity_id : int, target_peer_id : int) -> void:
	var player : Node3D = get_player_instance(entity_id)
	if player == null:
		return
		
	NetworkGlobals.send_packet_to_peer(
		PacketEnums.Type.PLAYER_SPAWN,
		{
			PacketEnums.FieldName.POSITION: player.global_position,
			PacketEnums.FieldName.PLAYER_PEER_ID: entity_peer_ids[entity_id],
			PacketEnums.FieldName.ROTATION: player.global_rotation.y
		},
		target_peer_id,
		entity_id
	)


## Handles a peer completing its handshake.
func _on_peer_became_ready(peer_id : int) -> void:
	if not NetworkHandler.is_server or peer_entity_ids.has(peer_id):
		return
		
	var entity_id : int = _spawn_player(peer_id, remote_player_scene)
	if entity_id == 0:
		NetworkHandler.disconnect_peer(peer_id)
		return
		
	# Send existing players to the joining peer.
	for existing_id : int in entity_peer_ids:
		if existing_id != entity_id:
			_send_player_spawn(existing_id, peer_id)
			
	# Announce the new player to all ready clients.
	var player : Node3D = get_player_instance(entity_id)
	if player != null:
		NetworkGlobals.broadcast_packet(
			PacketEnums.Type.PLAYER_SPAWN,
			{
				PacketEnums.FieldName.POSITION: player.global_position,
				PacketEnums.FieldName.PLAYER_PEER_ID: peer_id,
				PacketEnums.FieldName.ROTATION: player.global_rotation.y
			},
			entity_id
		)


## Handles incoming player lifecycle packets.
func _on_client_packet(packet : DecodedPacket) -> void:
	if packet == null or NetworkHandler.is_server:
		return
		
	match packet.packet_type_id:
		PacketEnums.Type.PLAYER_SPAWN:
			_handle_player_spawn(packet)
			
		PacketEnums.Type.ENTITY_DESPAWN:
			_remove_player(packet.entity_id)


## Creates the appropriate local representation of a spawned player.
func _handle_player_spawn(packet : DecodedPacket) -> void:
	if packet.entity_id < 1 or packet.entity_id > NetworkEntityManager.max_entity_id:
		return
		
	if entity_peer_ids.has(packet.entity_id):
		return
		
	var peer_id : int = packet.values.get(PacketEnums.FieldName.PLAYER_PEER_ID, 0)
	if peer_id < 1 or peer_entity_ids.has(peer_id):
		return
		
	var position : Vector3 = packet.values.get(PacketEnums.FieldName.POSITION, Vector3.ZERO)
	var rotation : float = packet.values.get(PacketEnums.FieldName.ROTATION, 0.0)
	
	var scene : PackedScene = (player_scene if peer_id == multiplayer.get_unique_id() else remote_player_scene)
	var player : Node3D = scene.instantiate() as Node3D
	if player == null:
		push_warning("Cannot create player: scene root must extend Node3D.")
		return
		
	add_child(player)
	player.global_position = position
	player.global_rotation.y = rotation
	
	if not NetworkEntityManager.register_entity(packet.entity_id, player):
		player.queue_free()
		return
		
	peer_entity_ids[peer_id] = packet.entity_id
	entity_peer_ids[packet.entity_id] = peer_id
	player_instances[packet.entity_id] = player


## Removes a player's registration and scene instance.
func _remove_player(entity_id : int) -> void:
	if not entity_peer_ids.has(entity_id):
		return
		
	var peer_id : int = entity_peer_ids[entity_id]
	var player : Node3D = player_instances.get(entity_id)
	
	NetworkEntityManager.unregister_entity(entity_id)
	
	peer_entity_ids.erase(peer_id)
	entity_peer_ids.erase(entity_id)
	player_instances.erase(entity_id)
	
	if is_instance_valid(player):
		player.queue_free()


## Removes disconnected players and notifies remaining clients.
func _on_peer_disconnected(peer_id : int) -> void:
	if not NetworkHandler.is_server:
		return
		
	var entity_id : int = get_peer_entity_id(peer_id)
	if entity_id == 0:
		return
		
	_remove_player(entity_id)
	
	NetworkGlobals.broadcast_packet(
		PacketEnums.Type.ENTITY_DESPAWN,
		{},
		entity_id
	)


## Clears player state when networking shuts down.
func _on_networking_shutdown() -> void:
	for entity_id : int in entity_peer_ids.keys():
		_remove_player(entity_id)
		
	_next_spawn_point_index = 0
