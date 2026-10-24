class_name EntityHealth
extends Node

## Manages an entity's health pool and its usage.


## Configuration

## Runtime State
var health : float = 0.0
var stats_controller: EntityStatsController

## Public Interface
# Returns the current health amount.
func setup(stats: EntityStatsController) -> void:
	stats_controller = stats
	
func get_health() -> float:
	return health


# Returns the maximum health amount defined by the configuration.
func get_max_health() -> float:
	return stats_controller.get_max_health()


# Returns whether the entity is alive.
func is_alive() -> bool:
	return health > 0.0


# Returns whether enough health is available to cover the supplied cost.
func can_afford(cost : float) -> bool:
	return health >= cost


# Applies damage to the entity's health pool.
func take_damage(amount : float) -> void:
	if amount <= 0.0:
		return
	
	health = _clamp_health(health - amount)


# Restores health to the entity's health pool.
func heal(amount : float) -> void:
	if amount <= 0.0:
		return
	
	health = _clamp_health(health + amount)


# Resets health to its configured maximum.
func reset() -> void:
	health = get_max_health()


## Internal Calculations
# Clamps health between zero and the configured maximum health.
func _clamp_health(value : float) -> float:
	return clampf(value, 0.0, get_max_health())


## Validation
func validate() -> void:
	#assert(stats != null, "EntityHealth requires an EntityStatsController.")
	assert(stats_controller.get_max_health() > 0.0, "EntityHealth requires max_health to be greater than zero.")
