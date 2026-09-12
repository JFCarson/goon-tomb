class_name EntityStateController
extends EntityController

## Controller for all of an entity's state components.


const STATES := EntityStateEnums.States


## Runtime State
var states : Dictionary[STATES, EntityState] = {}


## Signals
signal state_changed(target_state : STATES, value : int)


func _initialise_hook() -> void:
	states.clear()
	
	for i in config.state.tracked_states:
		states[i] = EntityState.new(EntityStateEnums.state_components[i])


## Public Interface
# Updates the target state's value to a new one.
func update(target_state : STATES, value : int) -> void:
	if target_state not in states:
		push_warning("Update attempted on invalid state: %s" % target_state)
		return
	
	if states[target_state].get_state() == value:
		return
	
	states[target_state].set_state(value)
	state_changed.emit(target_state, value)


# Returns the value of the requested state.
func check(target_state : STATES) -> int:
	if target_state not in states:
		push_warning("Check request attempted on invalid state: %s" % target_state)
		return -1
	
	return states[target_state].get_state()


## Validation
func _validate() -> void:
	assert(config.state != null, "EntityStateController requires an EntityStateConfig.")
	assert(config.state.tracked_states != null, "EntityStateController requires tracked states to be configured.")
	
	for target_state in config.state.tracked_states:
		assert(target_state in EntityStateEnums.state_components, "EntityStateController contains an invalid tracked state: %s." % target_state)
