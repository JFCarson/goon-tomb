class_name EntityFallDamage
extends Node

## Detects damaging falls and requests damage through the parent damage controller.


## Configuration
const MINIMUM_FALL_VELOCITY : float = 8.0
const DAMAGE_PERCENTAGE_PER_VELOCITY : float = 0.1

var damage_per_velocity : float:
	set(value):
		assert(value > 0.0, "EntityFallDamage requires maximum health to be greater than zero.")
		damage_per_velocity = value * DAMAGE_PERCENTAGE_PER_VELOCITY


## Runtime State
var was_airborne : bool = false
var maximum_fall_velocity : float = 0.0


## References
@onready var damage : EntityDamageController = get_parent()


## Public Interface
# Tracks the entity's fall and requests damage when it lands.
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
# Calculates damage based on the entity's maximum downward velocity.
func _apply_fall_damage() -> void:
	var fall_velocity : float = abs(maximum_fall_velocity)
	
	if fall_velocity <= MINIMUM_FALL_VELOCITY:
		return
	
	var excess_velocity : float = fall_velocity - MINIMUM_FALL_VELOCITY
	var damage_amount : float = excess_velocity * damage_per_velocity
	
	damage.take_damage(damage_amount)


## Validation
func _validate() -> void:
	assert(damage != null, "EntityFallDamage requires an EntityDamageController parent.")
	assert(damage_per_velocity > 0.0, "EntityFallDamage requires damage_per_velocity to be greater than zero.")
