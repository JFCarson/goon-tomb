class_name NetworkTestHarness
extends Control


# Runtime
var _status_label : Label
var _peer_id_label : Label
var _connected_peers_label : Label
var _event_log_label : Label


# Lifecycle
func _ready() -> void:
	_create_status_ui()
	_connect_multiplayer_signals()
	_refresh_status()


# UI
func _create_status_ui() -> void:
	var container : VBoxContainer = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("separation", 8)
	add_child(container)

	var title : Label = Label.new()
	title.text = "Network Test Harness"
	container.add_child(title)

	_status_label = Label.new()
	container.add_child(_status_label)

	_peer_id_label = Label.new()
	container.add_child(_peer_id_label)

	_connected_peers_label = Label.new()
	container.add_child(_connected_peers_label)

	var server_button : Button = Button.new()
	server_button.text = "Start Server"
	server_button.pressed.connect(_on_server_pressed)
	container.add_child(server_button)

	var client_button : Button = Button.new()
	client_button.text = "Connect Client"
	client_button.pressed.connect(_on_client_pressed)
	container.add_child(client_button)

	var refresh_button : Button = Button.new()
	refresh_button.text = "Refresh Status"
	refresh_button.pressed.connect(_refresh_status)
	container.add_child(refresh_button)

	_event_log_label = Label.new()
	_event_log_label.text = "Events:\nHarness ready."
	_event_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(_event_log_label)


# Signals
func _connect_multiplayer_signals() -> void:
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)

	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)

	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected)

	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)

	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)


# Actions
func _on_server_pressed() -> void:
	NetHandler.start_server()
	_log_event("Server start requested.")
	_refresh_status()


func _on_client_pressed() -> void:
	NetHandler.start_client()
	_log_event("Client connection requested.")
	_refresh_status()


# Status
func _refresh_status() -> void:
	var peer : MultiplayerPeer = multiplayer.multiplayer_peer

	if peer == null:
		_status_label.text = "Status: No multiplayer peer."
		_peer_id_label.text = "Local peer ID: Unassigned"
		_connected_peers_label.text = "Connected peers: None"
		return

	var status_text : String = "Unknown"

	match peer.get_connection_status():
		MultiplayerPeer.CONNECTION_DISCONNECTED:
			status_text = "Disconnected"
		MultiplayerPeer.CONNECTION_CONNECTING:
			status_text = "Connecting"
		MultiplayerPeer.CONNECTION_CONNECTED:
			status_text = "Connected"

	var role_text : String = "Client"
	if multiplayer.is_server():
		role_text = "Server"

	_status_label.text = "Role: %s | Status: %s" % [role_text, status_text]
	_peer_id_label.text = "Local peer ID: %s" % multiplayer.get_unique_id()

	if multiplayer.is_server():
		var peer_ids : PackedInt32Array = multiplayer.get_peers()
		_connected_peers_label.text = "Connected client IDs: %s" % str(peer_ids)
	else:
		_connected_peers_label.text = "Server peer ID: %s" % NetHandler.server_id


# Event handlers
func _on_connected_to_server() -> void:
	_log_event("Connected to server.")
	_refresh_status()


func _on_connection_failed() -> void:
	_log_event("Connection failed.")
	_refresh_status()


func _on_server_disconnected() -> void:
	_log_event("Server disconnected.")
	_refresh_status()


func _on_peer_connected(peer_id : int) -> void:
	_log_event("Peer connected: %s" % peer_id)
	_refresh_status()


func _on_peer_disconnected(peer_id : int) -> void:
	_log_event("Peer disconnected: %s" % peer_id)
	_refresh_status()


func _log_event(message : String) -> void:
	if _event_log_label == null:
		return

	var timestamp : String = Time.get_time_string_from_system()
	_event_log_label.text = "Events:\n%s\n%s" % [timestamp + " - " + message, _event_log_label.text.trim_prefix("Events:\n")]
