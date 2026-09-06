class_name EntityState
extends Node

## Base class for entity states.


# Runtime
var state_values : Variant
var state : int = 0


## Process
func _init(enum_values : Variant) -> void:
	assert(enum_values != null, "'%s' is not a valid enumerator." % str(enum_values))
	state_values = enum_values


## Public Interface
# Update the state to a new value.
func set_state(new_state: int) -> void:
	if new_state not in state_values.values():
		push_warning("Invalid state value received for enumerator '%s': %s" % [state_values, new_state])
		return
	
	if state == new_state:
		return
	
	state = new_state


# Get the current value of the state.
func get_state() -> int:
	return state
