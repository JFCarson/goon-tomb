class_name PlayerLifecycleState
extends Node

## Stores and manages the player's lifecycle state.
## Controls transitions between alive, downed and dead states.


# Configuration
@export var downed_enabled : bool = false
@export var bleed_out_duration : float = 30.0


# Runtime State
var lifecycle_state : PlayerEnumsOld.LifecycleState = PlayerEnumsOld.LifecycleState.ALIVE
var bleed_out_timer : float = 0.0


# Signals
signal state_changed(new_state : PlayerEnumsOld.LifecycleState)
signal bled_out


func _process(delta : float) -> void:
	if lifecycle_state != PlayerEnumsOld.LifecycleState.DOWNED:
		return
	
	bleed_out_timer -= delta
	
	if bleed_out_timer <= 0.0:
		bleed_out()


## Public Interface
# Returns the player's current lifecycle state.
func get_state() -> PlayerEnumsOld.LifecycleState:
	return lifecycle_state


# Returns whether the player is alive and able to perform normal gameplay.
func is_alive() -> bool:
	return lifecycle_state == PlayerEnumsOld.LifecycleState.ALIVE


# Returns whether the player is currently downed.
func is_downed() -> bool:
	return lifecycle_state == PlayerEnumsOld.LifecycleState.DOWNED


# Returns whether the player is dead.
func is_dead() -> bool:
	return lifecycle_state == PlayerEnumsOld.LifecycleState.DEAD


# Transitions the player into the downed state.
func down() -> void:
	if lifecycle_state != PlayerEnumsOld.LifecycleState.ALIVE:
		return
	
	if not downed_enabled:
		die()
		return
	
	_set_state(PlayerEnumsOld.LifecycleState.DOWNED)
	bleed_out_timer = bleed_out_duration


# Transitions the player into the dead state.
func die() -> void:
	if lifecycle_state == PlayerEnumsOld.LifecycleState.DEAD:
		return
	
	bleed_out_timer = 0.0
	_set_state(PlayerEnumsOld.LifecycleState.DEAD)


# Recovers the player from the downed state.
func recover() -> void:
	if lifecycle_state != PlayerEnumsOld.LifecycleState.DOWNED:
		return
	
	bleed_out_timer = 0.0
	_set_state(PlayerEnumsOld.LifecycleState.ALIVE)


# Resets the player from dead to alive.
func reset() -> void:
	bleed_out_timer = 0.0
	_set_state(PlayerEnumsOld.LifecycleState.ALIVE)


# Returns the remaining bleed-out time.
func get_bleed_out_time() -> float:
	return max(bleed_out_timer, 0.0)


## Internal State Management
func _set_state(new_state : PlayerEnumsOld.LifecycleState) -> void:
	if lifecycle_state == new_state:
		return
	
	lifecycle_state = new_state
	state_changed.emit(lifecycle_state)


func bleed_out() -> void:
	if lifecycle_state != PlayerEnumsOld.LifecycleState.DOWNED:
		return
	
	bled_out.emit()
	die()
