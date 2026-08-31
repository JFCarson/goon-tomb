class_name PlayerFallDamageHandler
extends Node

## Detects damaging falls and requests damage through the parent damage handler.


# Configuration
@export var minimum_fall_velocity : float = 12.0
@export var damage_per_velocity : float = 5.0


# Runtime State
var was_airborne : bool = false
var maximum_fall_velocity : float = 0.0


# References
@onready var damage : PlayerDamageHandler = get_parent()


## Public Interface
# Tracks the player's fall and applies damage when they land.
func update(is_on_floor : bool, velocity : Vector3) -> void:
	if not is_on_floor:
		was_airborne = true
		
		if velocity.y < maximum_fall_velocity:
			maximum_fall_velocity = velocity.y
		
		return
	
	if not was_airborne:
		return
	
	_apply_fall_damage()
	
	was_airborne = false
	maximum_fall_velocity = 0.0


## Internal Calculations
# Calculates and applies damage based on the player's maximum downward velocity.
func _apply_fall_damage() -> void:
	var fall_velocity : float = abs(maximum_fall_velocity)
	
	if fall_velocity < minimum_fall_velocity:
		return
	
	var excess_velocity : float = fall_velocity - minimum_fall_velocity
	var damage_amount : float = excess_velocity * damage_per_velocity
	
	damage.take_damage(damage_amount)
