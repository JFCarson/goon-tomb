class_name PlayerDamageHandler
extends Node

## Handles damage and healing requests made against the player.


# Controllers
var resources : PlayerResourceController
var state : PlayerStateController


# Signals
signal damage_taken(amount : float)
signal health_restored(amount : float)
signal died


## Public Interface
# Initialises the damage handler's dependencies.
func initialise(player_resources : PlayerResourceController, player_state : PlayerStateController) -> void:
	resources = player_resources
	state = player_state


# Applies damage to the player.
func take_damage(amount : float) -> void:
	if amount <= 0.0:
		return
	
	if state.is_dead():
		return
	
	var previous_health : float = resources.get_health()
	
	resources.take_damage(amount)
	
	var actual_damage : float = previous_health - resources.get_health()
	
	if actual_damage <= 0.0:
		return
	
	damage_taken.emit(actual_damage)
	
	if not resources.is_alive():
		if state.is_downed():
			state.die()
		else:
			state.down()


# Restores health to the player.
func heal(amount : float) -> void:
	if amount <= 0.0:
		return
	
	if not state.is_alive():
		return
	
	var previous_health : float = resources.get_health()
	resources.heal(amount)
	
	var actual_healing : float = resources.get_health() - previous_health
	if actual_healing <= 0.0:
		return
	
	health_restored.emit(actual_healing)
