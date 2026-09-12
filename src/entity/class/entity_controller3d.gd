class_name EntityController3D
extends Node3D

## Base class for 3D space-based controllers for entities.


## Configuration
# Reference to the config of the controller.
var config : EntityConfig


## Runtime State
# Reference to the entity's state and resource controllers. Null by default,
# and only updated if they actually exist.
var state : EntityStateController = null
var resource : EntityResourceController = null

# Flag to run debug functions.
var debug : bool = false


func initialise(state_controller : EntityStateController = null, resource_controller : EntityResourceController = null) -> void:
	if state_controller != null:
		state = state_controller
	
	if resource_controller != null:
		resource = resource_controller
	
	_validate_base()
	_initialise_hook()
	_validate()


## Hooks
# Provides a hook for initialisation that can be called by the orchestrator.
# Passes by default.
func _initialise_hook() -> void:
	pass


# Provides a hook for validation that can be overwritten by instances of the
# class. Passes by default.
func _validate() -> void:
	pass


## Validation
# Validates the requirements common to all 3D entity controllers.
func _validate_base() -> void:
	assert(config != null, "%s requires an EntityConfig." % get_class())
	
	if state != null:
		assert(state is EntityStateController, "%s received an invalid state controller." % get_class())
	
	if resource != null:
		assert(resource is EntityResourceController, "%s received an invalid resource controller." % get_class())
