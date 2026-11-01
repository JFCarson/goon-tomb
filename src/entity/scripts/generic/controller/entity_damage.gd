class_name EntityDamageController
extends EntityController

## Handles damage and healing requests made against an entity.


# Components
## Keeps reference to the component which handles fall damage calculations.
@export var fall_damage : EntityFallDamage

## Keeps reference to the component which handles death.
@export var death : EntityDeath


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	for component : EntityComponent in [fall_damage, death]:
		component.initialise(self)


# Public Interface
## Processes damage detection for the entity.
func process_damage() -> float:
	var total : float = 0.0
	
	total += fall_damage.calculate_damage()
	
	return take_damage(total)


## Applies damage to the entity.
func take_damage(amount : float) -> float:
	if amount <= 0.0:
		return 0.0
	
	if not entity.is_alive():
		return 0.0
	
	var previous_health : float = entity.stats.health.current
	
	entity.stats.health.damage(amount)
	
	var actual_damage : float = previous_health - entity.stats.health.current
	if actual_damage <= 0.0:
		return 0.0
	
	if entity.stats.health.current == entity.stats.health.min_value:
		death.down()
	
	return amount


## Restores health to the entity.
func heal(amount : float) -> float:
	if amount <= 0.0:
		return 0.0
	
	if not entity.is_alive():
		return 0.0
	
	var previous_health : float = entity.stats.health.current
	
	entity.stats.health.heal(amount)
	
	var actual_healing : float = entity.stats.health.current - previous_health
	
	if actual_healing <= 0.0:
		return 0.0
	
	return amount
