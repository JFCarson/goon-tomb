extends Node

## Handles low-level ENet networking for both server and client instances.
##
## This component wraps ENetConnection and translates ENet connection and
## packet events into signals that can be consumed by other game systems.


## Config
# Metadata key used to store the application's assigned peer ID on an ENet
# packet peer.
const meta_id : String = "id"

# Standard byte in a packet used to store the event type.
const event_type_byte_index : int = 0

# Standard byte in a packet used to store the peer ID.
const peer_byte_index : int = 1


## Signals: Server
# Signals that a peer has connected to the server.
signal on_peer_connected(peer_id : int)

# Signals that a peer has disconnected from the server.
signal on_peer_disconnected(peer_id : int)

# Signals that the server has received a packet from a peer.
signal on_server_packet(peer_id : int, data : PackedByteArray)


## Signals: Client
# Signals that the client has connected to the server.
signal on_connected_to_server()

# Signals that the client has disconnected from the server.
signal on_disconnected_from_server()

# Signals that the client has received a packet from the server.
signal on_client_packet(data : PackedByteArray)


## Runtime
# Reference to the ENet connection used by this application instance.
#
# On the server, this represents the server's listening host and manages all
# connected peers.
#
# On the client, this represents the client's ENet host and manages its
# connection to the server.
var connection : ENetConnection

# Determines whether the running instance of the application is the server.
var is_server : bool = false


## Runtime: Server
# Stores peer IDs that are currently available to assign to connecting
# clients.
#
# IDs are assigned from this array when a peer connects and returned to the           
# array when that peer disconnects.
var available_peer_ids : Array = range(255, -1, -1)

# Stores all currently connected client peers indexed by their assigned
# application peer ID.
var client_peers : Dictionary[int, ENetPacketPeer] = {}


## Runtime: Client
# Reference to the ENet peer representing the connection to the server.
var server_peer : ENetPacketPeer


## Process
func _process(_delta : float) -> void:
	# Do not attempt to service an uninitialised ENet connection.
	if connection == null:
		return
	
	# Process all pending ENet events.
	_handle_events()


## Public Interface
# Start the application as an ENet server.
#
# Creates a server that listens for incoming connections on the supplied IP
# address and port.
func start_server(ip_address : String = "127.0.0.1", port : int = 42069) -> void:
	connection = ENetConnection.new()
	
	var error : Error = connection.create_host_bound(ip_address, port)
	if error:
		print("Server failed to start: ", error_string(error))
		connection = null
		return
	
	print("Server started successfully.")
	is_server = true


# Start the application as an ENet client.
#
# Creates a client host and attempts to connect it to the supplied server
# address and port.
func start_client(ip_address : String = "127.0.0.1", port : int = 42069) -> void:
	connection = ENetConnection.new()
	
	var error : Error = connection.create_host(1)
	if error:
		print("Client failed to start: ", error_string(error))
		connection = null
		return
	
	print("Client started successfully.")
	server_peer = connection.connect_to_host(ip_address, port)


# Disconnect the client from the server.
#
# This function has no effect when called from a server instance.
func disconnect_client() -> void:
	if is_server:
		return
	
	server_peer.peer_disconnect()


## Private Methods
# Process all pending ENet events.
#
# ENet events include peers connecting, peers disconnecting, and packets being
# received. Events are translated into this component's signals so that other
# systems do not need to interact directly with ENet.
func _handle_events() -> void:
	var packet_event : Array = connection.service()
	var event_type : ENetConnection.EventType = packet_event[event_type_byte_index]
	
	while event_type != ENetConnection.EVENT_NONE:
		var peer : ENetPacketPeer = packet_event[peer_byte_index]
		
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("ENet connection resulted in an error: %s" % packet_event)
				return
			
			ENetConnection.EVENT_CONNECT:
				if is_server:
					_peer_connected(peer)
				else:
					_connected_to_server()
			
			ENetConnection.EVENT_DISCONNECT:
				if is_server:
					_peer_disconnected(peer)
				else:
					_disconnected_from_server()
					return
			
			ENetConnection.EVENT_RECEIVE:
				if is_server:
					on_server_packet.emit(peer.get_meta(meta_id), peer.get_packet())
				else:
					on_client_packet.emit(peer.get_packet())
		
		# Request the next pending ENet event.
		packet_event = connection.service()
		event_type = packet_event[event_type_byte_index]


## Private Methods: Server
# Handles a new client connection.
#
# Assigns the connecting peer an available application peer ID, stores that
# ID as metadata on the ENet peer, and adds the peer to the active client
# collection.
func _peer_connected(peer : ENetPacketPeer) -> void:
	var peer_id : int = available_peer_ids.pop_back()
	
	peer.set_meta(meta_id, peer_id)
	client_peers[peer_id] = peer
	
	print("Peer connected with assigned id: ", peer_id)
	
	on_peer_connected.emit(peer_id)


# Handles a client disconnecting from the server.
#
# Returns the peer's assigned ID to the available ID pool and removes the
# peer from the active client collection.
func _peer_disconnected(peer : ENetPacketPeer) -> void:
	var peer_id : int = peer.get_meta(meta_id)
	
	available_peer_ids.push_back(peer_id)
	client_peers.erase(peer_id)
	
	print("Peer ", peer_id, " disconnected from server.")
	
	on_peer_disconnected.emit(peer_id)


## Private Methods: Client
# Handles the client successfully connecting to the server.
func _connected_to_server() -> void:
	print("Successfully connected to server.")
	
	on_connected_to_server.emit()


# Handles the client disconnecting from the server.
func _disconnected_from_server() -> void:
	print("Successfully disconnected from server.")
	
	on_disconnected_from_server.emit()
	
	# Clear the connection reference so the client is no longer considered
	# connected.
	connection = null
