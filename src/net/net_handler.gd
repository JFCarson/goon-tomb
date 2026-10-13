extends Node

## Handles ENet transport and forwards received packet bytes.


## Config
# Maximum number of clients that can connect to the server.
const max_clients : int = 3

# Peer ID reserved for the server in Godot's high-level multiplayer API.
const server_id : int = 1


## Signals
# Emitted when the server receives bytes from a connected client.
signal on_server_packet(sender_peer_id : int, data : PackedByteArray)

# Emitted when the client receives bytes from the server.
signal on_client_packet(data : PackedByteArray)


## Runtime
# Active ENet peer used for the current server or client connection.
var multiplayer_peer : ENetMultiplayerPeer


## Process
# Connects to Godot's packet-received signal so incoming bytes can be
# forwarded to the appropriate networking coordinator.
func _ready() -> void:
	multiplayer.peer_packet.connect(_packet_received)


## Public Interface
# Starts an ENet server bound to the specified IP address and port.
# Closes any previously configured peer before creating the server.
func start_server(ip_address : String = "127.0.0.1", port : int = 42069) -> void:
	_close_peer()

	# Create a new ENet peer and configure the local address to bind to.
	var new_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	new_peer.set_bind_ip(ip_address)

	# Initialise the server with the configured port and client limit.
	var error : Error = new_peer.create_server(port, max_clients)

	# Do not configure the multiplayer API if server creation failed.
	if error != OK:
		push_error("Server failed to start: " + error_string(error))
		return

	# Store the peer and assign it to Godot's multiplayer API.
	multiplayer_peer = new_peer
	multiplayer.multiplayer_peer = multiplayer_peer

	print("Server started successfully.")


# Connects to an ENet server at the specified IP address and port.
# Closes any previously configured peer before creating the client.
func start_client(ip_address : String = "127.0.0.1", port : int = 42069) -> void:
	_close_peer()

	# Create a new ENet peer for the client connection.
	var new_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	# Initialise the connection to the remote server.
	var error : Error = new_peer.create_client(ip_address, port)

	# Do not configure the multiplayer API if client creation failed.
	if error != OK:
		push_error("Client failed to start: " + error_string(error))
		return

	# Store the peer and assign it to Godot's multiplayer API.
	multiplayer_peer = new_peer
	multiplayer.multiplayer_peer = multiplayer_peer

	print("Client started successfully.")


# Disconnects the client from its server.
func disconnect_client() -> void:
	if multiplayer_peer == null or multiplayer.is_server():
		return

	_close_peer()
	print("Client disconnected.")


# Stops the running server and closes its ENet peer.
func stop_server() -> void:
	if multiplayer_peer == null or not multiplayer.is_server():
		return

	_close_peer()
	print("Server stopped.")


# Sends raw packet bytes to the specified peer using the requested transfer mode.
# The caller is responsible for ensuring that the bytes are correctly encoded.
func send_bytes(data : PackedByteArray, target_peer_id : int, transfer_mode : MultiplayerPeer.TransferMode) -> void:
	# Sending requires an active multiplayer peer.
	if multiplayer_peer == null:
		push_error("Cannot send packet: no multiplayer peer is configured.")
		return

	# Empty byte arrays cannot represent a valid packet.
	if data.is_empty():
		push_error("Cannot send an empty packet.")
		return

	# Delegate transmission to Godot's multiplayer API.
	var error : Error = multiplayer.send_bytes(data, target_peer_id, transfer_mode)

	# Report transmission errors to help diagnose network issues.
	if error != OK:
		push_error("Failed to send packet: " + error_string(error))


# Sends raw packet bytes directly to the server.
func send_bytes_to_server(data : PackedByteArray, transfer_mode : MultiplayerPeer.TransferMode) -> void:
	send_bytes(data, server_id, transfer_mode)


# Sends raw packet bytes to all connected peers using peer ID zero.
func broadcast_bytes(data : PackedByteArray, transfer_mode : MultiplayerPeer.TransferMode) -> void:
	send_bytes(data, 0, transfer_mode)


## Private Methods
# Closes the current peer and clears it from the multiplayer API if it is
# the peer currently assigned to this node's multiplayer context.
func _close_peer() -> void:
	if multiplayer_peer == null:
		return

	# Detach the peer before closing it so the multiplayer API no longer
	# references the peer being shut down.
	if multiplayer.multiplayer_peer == multiplayer_peer:
		multiplayer.multiplayer_peer = null

	# Close the ENet connection and clear the stored reference.
	multiplayer_peer.close()
	multiplayer_peer = null


# Forwards incoming bytes without inspecting or decoding their contents.
func _packet_received(sender_peer_id : int, data : PackedByteArray) -> void:
	if multiplayer.is_server():
		on_server_packet.emit(sender_peer_id, data)
	else:
		on_client_packet.emit(data)
