class_name EntityStateController
extends EntityController

## Controller for all of an entity's state components.


const STATES := EntityStateEnums.States

# Runtime
var states : Dictionary[STATES, EntityState] = {}


## Process
func _initialise_hook() -> void:
	for i in config.state.tracked_states:
		states[i] = EntityState.new(EntityStateEnums.state_components[i])


## Public Interface
# Updates the target state's value to a new one.
func update(target_state : STATES, value : int) -> void:
	if target_state not in states:
		push_warning("Update attempted on invalid state: %s" % target_state)
		return
	states[target_state].set_state(value)


# Returns the value of the requested state.
func check(target_state : STATES) -> int:
	if target_state not in states:
		push_warning("Check request attempted on invalid state: %s" % target_state)
		return -1
	return states[target_state].get_state()
