extends Node

## Controls the test world.


# Process
func _enter_tree() -> void:
	print("Game entered the scene tree.")


func _ready() -> void:
	print("Game world ready.")
	print("Registered spawn points: ", NetworkPlayerManager.spawn_points.size())
	print("Is server: ", NetworkHandler.is_server)

	if not NetworkHandler.is_server:
		print("Skipping host player creation: this peer is not the server.")
		return

	print("Attempting to create host player.")

	var success : bool = NetworkPlayerManager.create_host_player()

	print("Host player creation result: ", success)

	if not success:
		push_error("Failed to create the host player.")
