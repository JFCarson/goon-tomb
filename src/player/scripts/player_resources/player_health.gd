class_name PlayerHealth
extends Node

## Manages the player's health pool and its usage.


# Configuration
@export var health_settings : PlayerHealthSettings


# Runtime State
var health : float


func _ready() -> void:
	health = health_settings.max_health


## Public Interface
# Returns the current health amount.
func get_health() -> float:
	return health


# Returns the maximum health amount defined by the configuration.
func get_max_health() -> float:
	return health_settings.max_health


# Returns whether the player is currently alive.
func is_alive() -> bool:
	return health > 0.0


# Returns whether enough health is available to cover the supplied cost.
func can_afford(cost : float) -> bool:
	return health >= cost


# Applies the supplied amount of damage.
func take_damage(amount : float) -> void:
	health = max(health - amount, 0.0)


# Restores the supplied amount of health.
func heal(amount : float) -> void:
	health = min(health + amount, health_settings.max_health)


# Resets health to its configured maximum.
func reset() -> void:
	health = health_settings.max_health
