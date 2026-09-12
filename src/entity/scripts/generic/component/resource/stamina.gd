class_name EntityStamina
extends Node

## Manages an entity's stamina pool, its usage, and its regeneration.


## Configuration
var stat_sheet : EntityStatSheet


## Runtime State
var stamina : float = 0.0
var stamina_regeneration_timer : float = 0.0


## Public Interface
# Returns the current stamina amount.
func get_stamina() -> float:
	return stamina


# Returns the maximum stamina amount defined by the configuration.
func get_max_stamina() -> float:
	return stat_sheet.max_stamina


# Returns whether the entity has enough stamina to sprint.
func can_sprint() -> bool:
	return stamina > 0.0


# Returns whether enough stamina is available to cover the supplied cost.
func can_afford(cost : float) -> bool:
	return stamina >= cost


# Returns whether the entity has enough stamina to jump.
func can_jump() -> bool:
	return can_afford(stat_sheet.jump_cost)


# Consumes the stamina cost associated with jumping.
func consume_jump() -> bool:
	return consume(stat_sheet.jump_cost)


# Consumes the supplied amount of stamina and starts the regeneration delay.
func consume(cost : float) -> bool:
	if cost <= 0.0 or not can_afford(cost):
		return false
	
	stamina = _clamp_stamina(stamina - cost)
	stamina_regeneration_timer = stat_sheet.regeneration_delay
	
	return true


# Updates stamina consumption and regeneration for the current frame.
func update(delta : float, is_sprinting : bool) -> void:
	if is_sprinting:
		_drain_stamina(delta)
		stamina_regeneration_timer = stat_sheet.regeneration_delay
	else:
		_regenerate(delta)


# Resets stamina to its configured maximum.
func reset() -> void:
	stamina = stat_sheet.max_stamina
	stamina_regeneration_timer = 0.0


## Internal Calculations
# Drains stamina while the entity is sprinting.
func _drain_stamina(delta : float) -> void:
	var drain : float = stat_sheet.sprint_drain_rate * delta
	stamina = _clamp_stamina(stamina - drain)


# Regenerates missing stamina once the regeneration delay has elapsed.
func _regenerate(delta : float) -> void:
	if stamina_regeneration_timer > 0.0:
		stamina_regeneration_timer = max(stamina_regeneration_timer - delta, 0.0)
		return
	
	if stamina >= stat_sheet.max_stamina:
		return
	
	var regeneration : float = stat_sheet.regeneration_rate * delta
	stamina = _clamp_stamina(stamina + regeneration)


# Clamps stamina between zero and the configured maximum stamina.
func _clamp_stamina(value : float) -> float:
	return clampf(value, 0.0, stat_sheet.max_stamina)


## Validation
func validate() -> void:
	assert(stat_sheet != null, "EntityStamina requires an EntityStatSheet.")
	assert(stat_sheet.max_stamina > 0.0, "EntityStamina requires max_stamina to be greater than zero.")
	assert(stat_sheet.jump_cost >= 0.0, "EntityStamina requires jump_cost to be zero or greater.")
	assert(stat_sheet.sprint_drain_rate >= 0.0, "EntityStamina requires sprint_drain_rate to be zero or greater.")
	assert(stat_sheet.regeneration_rate >= 0.0, "EntityStamina requires regeneration_rate to be zero or greater.")
	assert(stat_sheet.regeneration_delay >= 0.0, "EntityStamina requires regeneration_delay to be zero or greater.")
