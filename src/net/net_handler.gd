extends Node

## Handles network communication for the listen server.
##
## Configures ENet through Godot's MultiplayerAPI, manages network packet
## transmission, and forwards received packets to the appropriate systems.


## Config
# Maximum number of clients that the server will accept simultaneously.
const max_clients : int = 255

# Default peer ID for the server.
const server_id : int = 1


## Signals
# Signal that the server has received a packet from a peer.
signal on_server_packet(sender_peer_id : int, data : PackedByteArray)

# Signal that the client has received a packet from the server.
signal on_client_packet(data : PackedByteArray)


## Runtime
# Reference to the ENet multiplayer peer used by this application instance.
var multiplayer_peer : ENetMultiplayerPeer


## Process
func _ready() -> void:
	multiplayer.peer_packet.connect(_packet_received)


## Public Interface
# Start the application as an ENet server.
#
# Creates a server that listens for incoming connections on the supplied IP
# address and port.
func start_server(ip_address : String = "127.0.0.1", port : int = 42069) -> void:
	_close_peer()

	var new_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	new_peer.set_bind_ip(ip_address)

	var error : Error = new_peer.create_server(port, max_clients)

	if error != OK:
		push_error("Server failed to start: " + error_string(error))
		return

	multiplayer_peer = new_peer
	multiplayer.multiplayer_peer = multiplayer_peer

	print("Server started successfully.")


# Start the application as an ENet client.
#
# Creates a client and attempts to connect it to the supplied server address
# and port.
func start_client(ip_address : String = "127.0.0.1", port : int = 42069) -> void:
	_close_peer()

	var new_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	var error : Error = new_peer.create_client(ip_address, port)

	if error != OK:
		push_error("Client failed to start: " + error_string(error))
		return

	multiplayer_peer = new_peer
	multiplayer.multiplayer_peer = multiplayer_peer

	print("Client started successfully.")


# Disconnect the client from the server.
#
# This function has no effect when called from a server instance or when no
# multiplayer peer is currently configured.
func disconnect_client() -> void:
	if multiplayer_peer == null or multiplayer.is_server():
		return

	_close_peer()


# Encode a packet and send it directly to a specific multiplayer peer.
#
# The target peer ID identifies the peer that should receive the packet.
# Reports an error if the packet cannot be sent.
func send_packet(packet : Packet, target_peer_id : int) -> void:
	if multiplayer_peer == null:
		push_error("Cannot send packet: no multiplayer peer is configured.")
		return

	var error : Error = multiplayer.send_bytes( packet.encode(), target_peer_id, packet.transfer_mode)

	if error != OK:
		push_error("Failed to send packet: " + error_string(error))


# Encode a packet and send it directly to the server.
func send_packet_to_server(packet : Packet) -> void:
	send_packet(packet, server_id)


# Encode a packet and broadcast it to all connected multiplayer peers.
#
# A target peer ID of 0 instructs Godot's MultiplayerAPI to send the packet
# to all connected peers.
func broadcast_packet(packet : Packet) -> void:
	send_packet(packet, 0)


## Private Methods
# Close the current multiplayer peer and clear the configured peer reference.
func _close_peer() -> void:
	if multiplayer_peer == null:
		return

	if multiplayer.multiplayer_peer == multiplayer_peer:
		multiplayer.multiplayer_peer = null

	multiplayer_peer.close()
	multiplayer_peer = null


# Handles custom packet data received through the MultiplayerAPI.
#
# The peer ID supplied by MultiplayerAPI identifies the peer that sent the
# packet, rather than the peer that should receive it.
func _packet_received(sender_peer_id : int, data : PackedByteArray) -> void:
	if multiplayer.is_server():
		on_server_packet.emit(sender_peer_id, data)
	else:
		on_client_packet.emit(data)
