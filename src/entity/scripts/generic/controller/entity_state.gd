class_name EntityStateController
extends EntityController

## Controller for all of an entity's state components.


# Runtime
## Keeps reference to each initialised and tracked state belonging to the entity.
var states : Dictionary[EntityStateEnums.States, EntityState] = {}


# Signals
## Emitted when a state is updating, containing a payload which indicates which
## state changed, and to what new value.
signal state_changed(target_state : EntityStateEnums.States, value : int)


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	states.clear()
	
	for i in entity.config.state.tracked_states:
		states[i] = EntityState.new(EntityStateEnums.state_components[i])


# Public Interface
## Updates the target state's value to a new one.
func update(target_state : EntityStateEnums.States, value : int) -> void:
	if target_state not in states:
		push_warning("Update attempted on invalid state: %s" % target_state)
		return
	
	if states[target_state].get_state() == value:
		return
	
	states[target_state].set_state(value)
	state_changed.emit(target_state, value)


## Returns the value of the requested state.
func check(target_state : EntityStateEnums.States) -> int:
	if target_state not in states:
		push_warning("Check request attempted on invalid state: %s" % target_state)
		return -1
	
	return states[target_state].get_state()
