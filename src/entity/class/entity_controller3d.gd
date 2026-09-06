class_name EntityController3D
extends Node3D

## Base class for 3D space-based controllers for entities.


# Reference to the config of the controller.
var config : EntityConfig

# Reference to the entity's state controller. Null by default, and is only
# updated if one actually exists.
var state : EntityStateController = null

# Flag to run debug functions.
var debug : bool = false


func initialise(state_controller : EntityStateController = null) -> void:
	if state_controller != null:
		state = state_controller
	
	_initialise_hook()


## Process
func _ready() -> void:
	_on_ready()
	_validate()


## Hooks
# Provides a hook for initialisation that can be called by the orchestrator.
# Passes by default.
func _initialise_hook() -> void:
	pass
	

# Provides a hook for _ready that can be overwrtiten as required by instances of
# the class. Passes by default.
func _on_ready() -> void:
	pass


# Provides a hook for for validation that can be overwritten by instances of the
# class. Passes by default
func _validate() -> void:
	pass
