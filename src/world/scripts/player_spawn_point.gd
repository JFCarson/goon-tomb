class_name PlayerSpawnPoint
extends Marker3D

## Determines a point in the world where the player is able to spawn.


# Process
## Registers this spawn point when it enters the scene tree.
func _ready() -> void:
	NetworkPlayerManager.register_spawn_point(self)


## Unregisters this spawn point when it leaves the scene tree.
func _exit_tree() -> void:
	NetworkPlayerManager.unregister_spawn_point(self)
