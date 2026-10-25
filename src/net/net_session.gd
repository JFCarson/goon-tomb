extends Node

## Coordinates protocol negotiation and session readiness.
##
## Handshake packets are consumed here. Only packets from ready peers are
## allowed through to the existing gameplay-facing NetworkGlobals signals.


# Config
## Protocol version required by this build.
## Increment when a change makes the network wire protocol incompatible.
const protocol_version : int = 1

## Maximum time allowed for a handshake to complete, in seconds.
const handshake_timeout_seconds : float = 5.0

## Brief delay allowing a reliable rejection packet to reach the client.
const rejection_grace_seconds : float = 0.5


# States
## Current state of this client's session.
enum ClientState {
	DISCONNECTED,
	HANDSHAKING,
	READY,
	REJECTED
}

## Handshake state tracked independently for each remote peer on the server.
enum PeerState {
	PENDING,
	READY,
	REJECTED
}


# Runtime
## Current client-side session state.
var client_state : ClientState = ClientState.DISCONNECTED

## Handshake state indexed by remote peer ID on the server.
var peer_states : Dictionary[int, int] = {}

## Deadline, in ticks, for the client's current handshake.
var client_handshake_deadline_msec : int = 0

## Per-peer handshake or rejection deadlines, in ticks.
var peer_deadlines_msec : Dictionary[int, int] = {}


# Process
## Connects to transport lifecycle signals to track session readiness.
func _ready() -> void:
	if not NetHandler.connection_succeeded.is_connected(_on_connection_succeeded):
		NetHandler.connection_succeeded.connect(_on_connection_succeeded)
		
	if not NetHandler.connection_failed.is_connected(_on_connection_failed):
		NetHandler.connection_failed.connect(_on_connection_failed)
		
	if not NetHandler.server_disconnected.is_connected(_on_server_disconnected):
		NetHandler.server_disconnected.connect(_on_server_disconnected)
		
	if not NetHandler.peer_connected.is_connected(_on_peer_connected):
		NetHandler.peer_connected.connect(_on_peer_connected)
		
	if not NetHandler.peer_disconnected.is_connected(_on_peer_disconnected):
		NetHandler.peer_disconnected.connect(_on_peer_disconnected)
		
	if not NetHandler.networking_shutdown.is_connected(_on_networking_shutdown):
		NetHandler.networking_shutdown.connect(_on_networking_shutdown)


## Expires incomplete handshakes and disconnects rejected peers after the
## rejection response has had a short opportunity to be delivered.
func _process(_delta : float) -> void:
	var current_time_msec : int = Time.get_ticks_msec()
	
	# Enforce the client-side handshake timeout.
	if client_state == ClientState.HANDSHAKING:
		if current_time_msec >= client_handshake_deadline_msec:
			push_warning("Handshake timed out while connecting to the server.")
			client_state = ClientState.DISCONNECTED
			client_handshake_deadline_msec = 0
			NetHandler.disconnect_client()
			
	# Server-side deadlines are meaningful only while hosting.
	if NetHandler.multiplayer_peer == null or not multiplayer.is_server():
		return
		
	# Duplicate the keys so disconnecting peers cannot affect iteration.
	var peer_ids : Array[int] = []
	for peer_id : int in peer_deadlines_msec:
		peer_ids.append(peer_id)
		
	for peer_id : int in peer_ids:
		if current_time_msec < peer_deadlines_msec[peer_id]:
			continue
			
		var state : int = peer_states.get(peer_id, PeerState.PENDING)
		
		match state:
			PeerState.PENDING:
				push_warning("Peer %s handshake timed out." % peer_id)
				NetHandler.disconnect_peer(peer_id)
				_remove_peer(peer_id)
				
			PeerState.REJECTED:
				NetHandler.disconnect_peer(peer_id)
				_remove_peer(peer_id)


# Public Interface
## Routes a decoded server packet received by the client.
## Returns true only when the packet may be emitted to gameplay listeners.
func route_client_packet(packet : DecodedPacket) -> bool:
	# Only accept packets from the server peer.
	if packet.sender_peer_id != NetHandler.server_id:
		push_warning("Received a packet from an unexpected peer.")
		_reject_server_traffic()
		return false
	
	var packet_type_id : int = packet.packet_type_id
	
	# Handshake packets are consumed by the session layer.
	if packet_type_id == PacketEnums.Type.SERVER_HANDSHAKE:
		_handle_server_handshake(packet)
		return false
	
	# Reject client handshake packets received from the server.
	if packet_type_id == PacketEnums.Type.CLIENT_HANDSHAKE:
		push_warning("Received a client handshake from the server.")
		_reject_server_traffic()
		return false
	
	# No gameplay packet is permitted until the server has accepted us.
	if client_state != ClientState.READY:
		push_warning("Received a gameplay packet before the client session was ready.")
		_reject_server_traffic()
		return false
		
	return true


## Routes a decoded client packet received by the server.
## Returns true only when the packet may be emitted to gameplay listeners.
func route_server_packet(packet : DecodedPacket) -> bool:
	var peer_id : int = packet.sender_peer_id
	var packet_type_id : int = packet.packet_type_id
	
	# Handshake packets are consumed by the session layer.
	if packet_type_id == PacketEnums.Type.CLIENT_HANDSHAKE:
		_handle_client_handshake(peer_id, packet)
		return false
	
	# Reject server handshake packets received from a client.
	if packet_type_id == PacketEnums.Type.SERVER_HANDSHAKE:
		push_warning("Peer %s sent a server handshake." % peer_id)
		NetHandler.disconnect_peer(peer_id)
		_remove_peer(peer_id)
		return false
	
	# Reject gameplay traffic from peers that have not completed negotiation.
	if peer_states.get(peer_id, PeerState.PENDING) != PeerState.READY:
		push_warning("Peer %s sent a gameplay packet before completing its handshake." % peer_id)
		NetHandler.disconnect_peer(peer_id)
		_remove_peer(peer_id)
		return false
		
	return true


## Determines whether the local client may send a given packet type.
## The client handshake is the only packet allowed before session readiness.
func can_send_packet_to_server(packet_type_id : int) -> bool:
	if packet_type_id == PacketEnums.Type.CLIENT_HANDSHAKE:
		return client_state == ClientState.HANDSHAKING
		
	# The server handshake must never be sent by a client.
	if packet_type_id == PacketEnums.Type.SERVER_HANDSHAKE:
		return false
		
	return client_state == ClientState.READY


## Determines whether the server may send a packet to a given peer.
## Handshake responses are allowed for any peer with tracked session state.
func can_send_packet_to_peer(packet_type_id : int, peer_id : int) -> bool:
	if packet_type_id == PacketEnums.Type.SERVER_HANDSHAKE:
		return peer_states.has(peer_id)
		
	# The client handshake must never be sent by the server.
	if packet_type_id == PacketEnums.Type.CLIENT_HANDSHAKE:
		return false
		
	return peer_states.get(peer_id, PeerState.PENDING) == PeerState.READY


## Returns whether a remote peer has completed the handshake.
func is_peer_ready(peer_id : int) -> bool:
	return peer_states.get(peer_id, PeerState.PENDING) == PeerState.READY


# Private Methods

## Processes the client's handshake request on the server.
func _handle_client_handshake(peer_id : int, packet : DecodedPacket) -> void:
	# Only a known peer in the pending state may initiate the handshake.
	if not peer_states.has(peer_id):
		NetHandler.disconnect_peer(peer_id)
		return
		
	if peer_states[peer_id] != PeerState.PENDING:
		push_warning("Peer %s sent a duplicate or unexpected handshake." % peer_id)
		NetHandler.disconnect_peer(peer_id)
		_remove_peer(peer_id)
		return
		
	var values : Dictionary = packet.values
	var received_version : int = values.get(PacketEnums.FieldName.PROTOCOL_VERSION, -1)
	
	# Incompatible clients receive a rejection before being disconnected.
	if received_version != protocol_version:
		push_warning("Rejected peer %s: protocol version %s does not match server version %s." % [peer_id, received_version, protocol_version])
		
		peer_states[peer_id] = PeerState.REJECTED
		peer_deadlines_msec[peer_id] = Time.get_ticks_msec() + int(rejection_grace_seconds * 1000.0)
		
		var rejection_sent : bool = NetworkGlobals.send_packet_to_peer(
			PacketEnums.Type.SERVER_HANDSHAKE,
			{
				PacketEnums.FieldName.PROTOCOL_VERSION: protocol_version,
				PacketEnums.FieldName.ACCEPTED: false
			},
			peer_id
		)
		
		# Disconnect immediately if the rejection could not be sent.
		if not rejection_sent:
			NetHandler.disconnect_peer(peer_id)
			_remove_peer(peer_id)
			
		return
		
	# Send acceptance while the peer is still pending.
	var acceptance_sent : bool = NetworkGlobals.send_packet_to_peer(
		PacketEnums.Type.SERVER_HANDSHAKE,
		{
			PacketEnums.FieldName.PROTOCOL_VERSION: protocol_version,
			PacketEnums.FieldName.ACCEPTED: true
		},
		peer_id
	)
	
	# Never mark the peer ready if the acceptance send failed.
	if not acceptance_sent:
		push_warning("Failed to send handshake acceptance to peer %s." % peer_id)
		NetHandler.disconnect_peer(peer_id)
		_remove_peer(peer_id)
		return
		
	peer_states[peer_id] = PeerState.READY
	peer_deadlines_msec.erase(peer_id)
	
	print("Peer %s completed the protocol handshake." % peer_id)



## Processes the server's handshake response on the client.
func _handle_server_handshake(packet : DecodedPacket) -> void:
	if client_state != ClientState.HANDSHAKING:
		push_warning("Received an unexpected server handshake.")
		_reject_server_traffic()
		return
		
	var values : Dictionary = packet.values
	var received_version : int = values.get(PacketEnums.FieldName.PROTOCOL_VERSION, -1)
	var accepted : bool = values.get(PacketEnums.FieldName.ACCEPTED, false)
	
	# Require both an explicit acceptance and a matching protocol version.
	if not accepted or received_version != protocol_version:
		push_warning("Server rejected the handshake or reported an incompatible protocol version.")
		client_state = ClientState.REJECTED
		client_handshake_deadline_msec = 0
		NetHandler.disconnect_client()
		
		return
		
	client_state = ClientState.READY
	client_handshake_deadline_msec = 0
	
	print("Protocol handshake completed successfully.")


## Disconnects a client that sends gameplay traffic before session readiness.
func _reject_server_traffic() -> void:
	client_state = ClientState.REJECTED
	client_handshake_deadline_msec = 0
	NetHandler.disconnect_client()


## Removes all server-side tracking for a peer.
func _remove_peer(peer_id : int) -> void:
	peer_states.erase(peer_id)
	peer_deadlines_msec.erase(peer_id)


# Signal Methods
## Starts the client handshake after ENet reports a successful connection.
func _on_connection_succeeded() -> void:
	client_state = ClientState.HANDSHAKING
	client_handshake_deadline_msec = (Time.get_ticks_msec() + int(handshake_timeout_seconds * 1000.0))
	NetworkGlobals.send_packet_to_server(PacketEnums.Type.CLIENT_HANDSHAKE, { PacketEnums.FieldName.PROTOCOL_VERSION: protocol_version })


## Resets client state after a failed connection attempt.
func _on_connection_failed() -> void:
	client_state = ClientState.DISCONNECTED
	client_handshake_deadline_msec = 0


## Resets all session state after the client loses its server connection.
func _on_server_disconnected() -> void:
	client_state = ClientState.DISCONNECTED
	client_handshake_deadline_msec = 0
	peer_states.clear()
	peer_deadlines_msec.clear()


## Creates pending handshake state when a remote peer connects to the server.
func _on_peer_connected(peer_id : int) -> void:
	if NetHandler.multiplayer_peer == null or not multiplayer.is_server():
		return
		
	peer_states[peer_id] = PeerState.PENDING
	peer_deadlines_msec[peer_id] = (Time.get_ticks_msec() + int(handshake_timeout_seconds * 1000.0))


## Removes peer readiness state after a remote peer disconnects.
func _on_peer_disconnected(peer_id : int) -> void:
	if NetHandler.multiplayer_peer == null or not multiplayer.is_server():
		return
		
	_remove_peer(peer_id)


## Clears all session state when the transport is shut down.
func _on_networking_shutdown() -> void:
	client_state = ClientState.DISCONNECTED
	client_handshake_deadline_msec = 0
	peer_states.clear()
	peer_deadlines_msec.clear()
