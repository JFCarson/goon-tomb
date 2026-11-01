extends Control

## Provides a simple interface for testing multiplayer connections.


# Signals
## Requests that the main scene load the game world.
signal world_load_requested(world_scene : PackedScene, create_host : bool)


# Config
## World scene loaded by both the host and clients.
var world_scene : PackedScene = preload("uid://bp2356hmcdw7")


# Nodes
@onready var host_button : Button = $CenterContainer/VBoxContainer/HostButton
@onready var join_button : Button = $CenterContainer/VBoxContainer/JoinButton
@onready var status_label : Label = $CenterContainer/VBoxContainer/StatusLabel


# Process
func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)


# Button Methods
## Starts a server and loads the test world.
func _on_host_pressed() -> void:
	if world_scene == null:
		_set_status("World scene has not been assigned.")
		return
		
	if not NetworkHandler.start_server():
		_set_status("Failed to start server.")
		return
		
	_set_status("Server started. Loading world...")
	_load_world(true)
	world_load_requested.emit(world_scene, true)


## Connects to a server and loads the test world.
func _on_join_pressed() -> void:
	if world_scene == null:
		_set_status("World scene has not been assigned.")
		return
		
	if not NetworkHandler.start_client():
		_set_status("Failed to start client.")
		return
		
	_set_status("Connecting...")
	_load_world(false)
	world_load_requested.emit(world_scene, false)


# Private Methods
## Loads the world and creates the host player when appropriate.
func _load_world(create_host : bool) -> void:
	var scene_tree : SceneTree = get_tree()
	
	var error : Error = scene_tree.change_scene_to_packed(world_scene)
	if error != OK:
		push_error("Failed to load world. Error: %s" % error)
		return
		
	# Wait until the new world root is available.
	var world : Node = null
	
	while world == null:
		await scene_tree.process_frame
		
		for child : Node in scene_tree.root.get_children():
			if child.name == "Game":
				world = child
				break
				
	if not world.has_signal("world_ready"):
		push_error("Game world is missing its world_ready signal.")
		return
		
	await world.world_ready
	
	if create_host:
		var success : bool = NetworkPlayerManager.create_host_player()
		print("Host player creation result: ", success)
		
		if not success:
			push_error("Failed to create the host player.")


## Creates the host player after the world has loaded.
func _create_host_player() -> void:
	if not NetworkHandler.is_server:
		return
		
	if not NetworkPlayerManager.create_host_player():
		push_error("Failed to create the host player.")


## Updates the visible connection status.
func _set_status(message : String) -> void:
	status_label.text = message
