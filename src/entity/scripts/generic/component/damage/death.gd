class_name EntityDeath
extends Node

## Handles lifecycle behaviour caused by damage and other gameplay events.
## The current lifecycle value is stored by EntityStateController.


## Configuration
@export var downed_enabled : bool = false
const BLEED_OUT_DURATION : float = 30.0


## Runtime State
var bleed_out_timer : float = 0.0

var state : EntityStateController


## Signals
signal state_changed(new_state : EntityStateEnums.Lifecycle)
signal bled_out


func initialise(state_controller : EntityStateController) -> void:
	state = state_controller
	
	_validate()


func _process(delta : float) -> void:
	if get_state() != EntityStateEnums.Lifecycle.DOWNED:
		return
	
	bleed_out_timer -= delta
	
	if bleed_out_timer <= 0.0:
		bleed_out()


## Public Interface
# Returns the current lifecycle state.
func get_state() -> EntityStateEnums.Lifecycle:
	return state.check(EntityStateEnums.States.LIFECYCLE) as EntityStateEnums.Lifecycle


# Transitions the entity into the downed state.
func down() -> void:
	if get_state() != EntityStateEnums.Lifecycle.ALIVE:
		return
	
	if not downed_enabled:
		die()
		return
	
	bleed_out_timer = BLEED_OUT_DURATION
	_set_state(EntityStateEnums.Lifecycle.DOWNED)


# Transitions the entity into the dead state.
func die() -> void:
	if get_state() == EntityStateEnums.Lifecycle.DEAD:
		return
	
	bleed_out_timer = 0.0
	_set_state(EntityStateEnums.Lifecycle.DEAD)


# Recovers the entity from the downed state.
func recover() -> void:
	if get_state() != EntityStateEnums.Lifecycle.DOWNED:
		return
	
	bleed_out_timer = 0.0
	_set_state(EntityStateEnums.Lifecycle.ALIVE)


# Resets the entity to its initial alive state.
func reset() -> void:
	bleed_out_timer = 0.0
	_set_state(EntityStateEnums.Lifecycle.ALIVE)


# Returns the remaining bleed-out time.
func get_bleed_out_time() -> float:
	return max(bleed_out_timer, 0.0)


# Transitions a downed entity into the dead state.
func bleed_out() -> void:
	if get_state() != EntityStateEnums.Lifecycle.DOWNED:
		return
	
	bled_out.emit()
	die()


## Internal State Management
func _set_state(new_state : EntityStateEnums.Lifecycle) -> void:
	if state.check(EntityStateEnums.States.LIFECYCLE) == new_state:
		return
	
	state.update(EntityStateEnums.States.LIFECYCLE, new_state)
	state_changed.emit(new_state)


## Validation
func _validate() -> void:
	assert(state != null, "EntityDeath requires an EntityStateController.")
	assert(state.check(EntityStateEnums.States.LIFECYCLE) != -1, "EntityDeath requires the LIFECYCLE state to be tracked.")
