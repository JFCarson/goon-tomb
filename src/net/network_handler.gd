extends Node

## Handles ENet transport and forwards received packet bytes.
## Assumes this node and its callers use the default SceneTree MultiplayerAPI.


# Config
## Maximum number of clients that can connect to the server.
##
## The host is not included in this number; consider n + 1 as the total player
## count.
const max_clients : int = 3

## Peer ID reserved for the server in the multiplayer API.
const server_id : int = 1

## Peer ID reserved to reference all connected clients.
const all_clients : int = 0


# Signals
## Emitted when this client successfully connects to the server.
signal connection_succeeded

## Emitted when this client's attempt to connect to the server fails.
signal connection_failed

## Emitted when a remote peer connects to the multiplayer session.
signal peer_connected(peer_id : int)

## Emitted when a remote peer disconnects from the multiplayer session.
signal peer_disconnected(peer_id : int)

## Emitted when this client loses its connection to the server.
signal server_disconnected

## Emitted when a configured networking peer is shut down.
signal networking_shutdown

## Emitted when the server receives bytes from a connected client.
signal on_server_packet(sender_peer_id : int, data : PackedByteArray)

## Emitted when the client receives bytes from the server.
signal on_client_packet(sender_peer_id : int, data : PackedByteArray)


# Runtime
## Active ENet peer used for the current server or client connection.
var multiplayer_peer : ENetMultiplayerPeer

## Whether this instance successfully created a server peer.
##
## Tracks the role established during peer setup rather than querying the
## multiplayer API during packet routing or teardown.
var is_server : bool = false


# Process
## Connects to Godot's multiplayer signals so connection events and incoming
## packet bytes can be forwarded to the appropriate networking coordinator.
func _ready() -> void:
	if not multiplayer.connected_to_server.is_connected(_on_connection_succeeded):
		multiplayer.connected_to_server.connect(_on_connection_succeeded)
		
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
		
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
		
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected)
		
	if not multiplayer.peer_packet.is_connected(_on_packet_received):
		multiplayer.peer_packet.connect(_on_packet_received)


# Public Interface
## Starts an ENet server bound to the specified IP address and port.
## Refuses to start if this instance is already hosting.
## Shuts down any previously configured peer before creating the server.
func start_server(ip_address : String = "127.0.0.1", port : int = 42069) -> bool:
	if is_server and _has_active_peer():
		push_warning("Cannot start server: a server is already running.")
		return false
		
	shutdown()
	
	var new_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	new_peer.set_bind_ip(ip_address)
	
	var error : Error = new_peer.create_server(port, max_clients)
	
	if error != OK:
		new_peer.close()
		push_error("Server failed to start: " + error_string(error))
		return false
		
	# Establish the local role before assigning the peer to the API.
	multiplayer_peer = new_peer
	is_server = true
	multiplayer.multiplayer_peer = multiplayer_peer
	
	print("Server started successfully.")
	
	return true


## Connects to an ENet server at the specified IP address and port.
## Shuts down any previously configured peer before creating the client.
func start_client(ip_address : String = "127.0.0.1", port : int = 42069) -> bool:
	shutdown()
	
	var new_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error : Error = new_peer.create_client(ip_address, port)
	
	if error != OK:
		push_error("Client failed to start: " + error_string(error))
		return false
		
	multiplayer_peer = new_peer
	is_server = false
	multiplayer.multiplayer_peer = multiplayer_peer
	
	print("Client connection initiated; awaiting server response.")
	
	return true


## Disconnects the client from its server.
## Does nothing if no peer is configured or this instance is hosting a server.
func disconnect_client() -> void:
	if multiplayer_peer == null:
		return
		
	if is_server:
		push_warning("Cannot disconnect client: this instance is hosting a server.")
		return
		
	shutdown()
	print("Client disconnected.")


## Disconnects a specific remote peer.
## Only the server may call this method.
func disconnect_peer(peer_id : int) -> void:
	if not _has_active_peer():
		push_error("Cannot disconnect peer: no active networking peer is configured.")
		return
		
	if not is_server:
		push_error("Cannot disconnect peer: this instance is not the server.")
		return
		
	if peer_id == server_id:
		push_error("Cannot disconnect peer: the target is the server peer ID.")
		return
		
	if not multiplayer.get_peers().has(peer_id):
		push_warning("Cannot disconnect peer: target peer is not connected.")
		return
		
	multiplayer_peer.disconnect_peer(peer_id, true)


## Stops the running server and closes its ENet peer.
## Does nothing if no peer is configured or this instance is not hosting a server.
func stop_server() -> void:
	if multiplayer_peer == null:
		return
		
	if not is_server:
		push_warning("Cannot stop server: this instance is not hosting a server.")
		return
		
	shutdown()
	print("Server stopped.")


## Shuts down the currently configured peer, regardless of its role.
## Use this for deliberate role switches or general connection cleanup.
func shutdown() -> void:
	var had_peer : bool = multiplayer_peer != null
	_close_peer()
	
	if had_peer:
		networking_shutdown.emit()


## Sends raw packet bytes to the server.
## Only a connected client may call this method.
func send_bytes_to_server(data : PackedByteArray, transfer_mode : MultiplayerPeer.TransferMode) -> void:
	if not _has_active_peer():
		push_error("Cannot send packet: no active networking peer is configured.")
		return
		
	if is_server:
		push_error("Cannot send a client request: this instance is the server.")
		return
		
	if multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		push_error("Cannot send packet: client is not connected to the server.")
		return
		
	_send_bytes(data, server_id, transfer_mode)


## Sends raw packet bytes to a specific connected client.
## Only the server may call this method.
func send_bytes_to_peer(data : PackedByteArray, target_peer_id : int, transfer_mode : MultiplayerPeer.TransferMode) -> bool:
	if not _has_active_peer():
		push_error("Cannot send packet: no active networking peer is configured.")
		return false
		
	if not is_server:
		push_error("Cannot send packet to a peer: this instance is not the server.")
		return false
		
	if target_peer_id == server_id:
		push_error("Cannot send a server-to-client packet to the server peer ID.")
		return false
		
	if not multiplayer.get_peers().has(target_peer_id):
		push_error("Cannot send packet: target peer is not connected.")
		return false
		
	return _send_bytes(data, target_peer_id, transfer_mode)


## Broadcasts raw packet bytes to all connected clients.
## Only the server may call this method.
func broadcast_bytes(data : PackedByteArray, transfer_mode : MultiplayerPeer.TransferMode) -> void:
	if not _has_active_peer():
		push_error("Cannot broadcast packet: no active networking peer is configured.")
		return
		
	if not is_server:
		push_error("Cannot broadcast packet: this instance is not the server.")
		return
		
	_send_bytes(data, all_clients, transfer_mode)


# Private Methods
## Returns whether this node's peer is the one currently assigned to the API.
func _has_active_peer() -> bool:
	return (multiplayer_peer != null and multiplayer.multiplayer_peer == multiplayer_peer)


## Closes the current peer and clears it from the multiplayer API if it is
## the peer currently assigned to this node's multiplayer context.
func _close_peer() -> void:
	var peer_to_close: ENetMultiplayerPeer = multiplayer_peer
	
	# Clear local state first so any late callbacks cannot treat this peer
	# as the active connection.
	multiplayer_peer = null
	is_server = false
	
	if peer_to_close == null:
		return
		
	if multiplayer.multiplayer_peer == peer_to_close:
		multiplayer.multiplayer_peer = null
		
	peer_to_close.close()



## Sends bytes after validating the active peer, payload and transfer mode.
## Returns true when the transport accepts the packet.
func _send_bytes(data : PackedByteArray, target_peer_id : int, transfer_mode : MultiplayerPeer.TransferMode) -> bool:
	if not _has_active_peer():
		push_error("Cannot send packet: networking peer is no longer active.")
		return false
		
	if data.is_empty():
		push_error("Cannot send an empty packet.")
		return false
		
	if (
		transfer_mode != MultiplayerPeer.TRANSFER_MODE_RELIABLE
		and transfer_mode != MultiplayerPeer.TRANSFER_MODE_UNRELIABLE
		and transfer_mode != MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
	):
		push_error("Cannot send packet: unsupported transfer mode.")
		return false
		
	var error : Error = multiplayer.send_bytes(data, target_peer_id, transfer_mode)
	
	if error != OK:
		push_error("Failed to send packet: " + error_string(error))
		return false
		
	return true



# Signal Methods
## Handles a successful client connection.
func _on_connection_succeeded() -> void:
	if is_server:
		push_warning("Received a client connection-success event on the server.")
		return
		
	print("Connected to server successfully.")
	connection_succeeded.emit()


## Handles a failed client connection attempt.
func _on_connection_failed() -> void:
	print("Failed to connect to server.")
	shutdown()
	connection_failed.emit()


## Handles a peer joining the multiplayer session.
func _on_peer_connected(peer_id: int) -> void:
	print("Peer connected: ", peer_id)
	peer_connected.emit(peer_id)


## Handles a peer leaving the multiplayer session.
func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer disconnected: ", peer_id)
	peer_disconnected.emit(peer_id)


## Handles the client losing its connection to the server.
func _on_server_disconnected() -> void:
	print("Disconnected from server.")
	shutdown()
	server_disconnected.emit()


## Routes incoming bytes according to the established role and transport sender.
##
## In the client/server ENet topology, packets received from peer ID 1 are
## server-to-client packets. Packets received from other peer IDs are
## client-to-server packets and should only be received by the server.
func _on_packet_received(sender_peer_id : int, data : PackedByteArray) -> void:
	if not _has_active_peer():
		push_warning("Ignoring received packet: no active networking peer is configured.")
		return
		
	if sender_peer_id == server_id:
		if is_server:
			push_warning("Ignoring packet from the server peer ID on a server instance.")
			return
			
		on_client_packet.emit(sender_peer_id, data)
		return
		
	if not is_server:
		push_warning("Ignoring packet from unexpected peer ID %s on a client instance." % sender_peer_id)
		return
		
	on_server_packet.emit(sender_peer_id, data)
