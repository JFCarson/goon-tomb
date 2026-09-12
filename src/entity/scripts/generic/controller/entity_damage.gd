class_name EntityDamageController
extends EntityController

## Handles damage and healing requests made against an entity.


## Components
@onready var fall_damage : EntityFallDamage = $EntityFallDamage
@onready var death : EntityDeath = $EntityDeath


## Signals
signal damage_taken(amount : float)
signal health_restored(amount : float)


func _initialise_hook() -> void:
	fall_damage.damage_per_velocity = config.stats.max_health
	death.initialise(state)


## Public Interface
# Applies damage to the entity.
func take_damage(amount : float) -> void:
	if amount <= 0.0:
		return
	
	if resource == null or not resource.is_alive():
		return
	
	var previous_health : float = resource.get_health()
	
	resource.take_damage(amount)
	
	var actual_damage : float = previous_health - resource.get_health()
	
	if actual_damage <= 0.0:
		return
	
	damage_taken.emit(actual_damage)
	
	if not resource.is_alive():
		death.down()


# Restores health to the entity.
func heal(amount : float) -> void:
	if amount <= 0.0:
		return
	
	if resource == null or not resource.is_alive():
		return
	
	var previous_health : float = resource.get_health()
	
	resource.heal(amount)
	
	var actual_healing : float = resource.get_health() - previous_health
	
	if actual_healing <= 0.0:
		return
	
	health_restored.emit(actual_healing)


# Updates fall damage detection.
func update_fall_damage(is_on_floor : bool, velocity : Vector3) -> void:
	fall_damage.update(is_on_floor, velocity)


## Validation
func _validate() -> void:
	assert(state != null, "EntityDamageController requires an EntityStateController.")
	assert(resource != null, "EntityDamageController requires an EntityResourceController.")
	assert(fall_damage != null, "EntityDamageController requires an EntityFallDamage component.")
	assert(death != null, "EntityDamageController requires an EntityDeath component.")
	assert(fall_damage.damage_per_velocity > 0.0, "EntityDamageController requires fall damage to have a positive damage_per_velocity.")
