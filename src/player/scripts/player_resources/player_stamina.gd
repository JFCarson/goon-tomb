class_name PlayerStamina
extends Node

## Manages the player's stamina pool, and its usage and regeneration.


# Configuration
@export var stamina_settings : PlayerStaminaSettings


# Runtime State
var stamina : float
var stamina_regeneration_timer : float = 0.0


func _ready() -> void:
	stamina = stamina_settings.max_stamina


## Public Interface
# Returns the current stamina amount.
func get_stamina() -> float:
	return stamina


# Returns the maximum stamina amount defined by the configuration.
func get_max_stamina() -> float:
	return stamina_settings.max_stamina


# Returns whether the player has enough stamina to sprint.
func can_sprint() -> bool:
	return stamina > 0.0


# Returns whether enough stamina is available to cover the supplied cost.
func can_afford(cost : float) -> bool:
	return stamina >= cost


# Returns whether the player has enough stamina to jump.
func can_jump() -> bool:
	return can_afford(stamina_settings.jump_cost)


# Consumes the stamina cost associated with jumping.
func consume_jump() -> bool:
	return consume(stamina_settings.jump_cost)


# Consumes the supplied amount of stamina and starts the regeneration delay.
func consume(cost : float) -> bool:
	if not can_afford(cost):
		return false
	
	stamina -= cost
	stamina_regeneration_timer = stamina_settings.regeneration_delay
	
	return true


# Updates stamina consumption and regeneration for the current frame.
func update(delta : float, is_sprinting : bool) -> void:
	if is_sprinting:
		stamina -= stamina_settings.sprint_drain_rate * delta
		stamina = max(stamina, 0.0)
		stamina_regeneration_timer = stamina_settings.regeneration_delay
	else:
		_regenerate(delta)


## Internal Calculations
# Regenerates missing stamina once the regeneration delay has elapsed.
func _regenerate(delta : float) -> void:
	if stamina_regeneration_timer > 0.0:
		stamina_regeneration_timer -= delta
		return
	
	if stamina == stamina_settings.max_stamina:
		return
	
	stamina = min(stamina + stamina_settings.regeneration_rate * delta, stamina_settings.max_stamina)
