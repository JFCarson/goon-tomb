class_name EntityState
extends Node

## Base class for entity states.


## Runtime State
var state_values : Variant
var state : int = 0


func _init(enum_values : Variant) -> void:
	assert(enum_values != null, "EntityState requires a valid enum dictionary.")
	assert(enum_values is Dictionary, "EntityState requires enum values to be supplied as a Dictionary.")
	
	state_values = enum_values
	
	assert(state in state_values.values(), "EntityState requires the supplied enum to contain the default state value 0.")


## Public Interface
# Updates the state to a new value.
func set_state(new_state : int) -> void:
	if new_state not in state_values.values():
		push_warning("Invalid state value received for enumerator '%s': %s" % [state_values, new_state])
		return
	
	if state == new_state:
		return
	
	state = new_state


# Returns the current value of the state.
func get_state() -> int:
	return state
