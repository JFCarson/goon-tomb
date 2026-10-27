class_name EntityDamageController
extends EntityController

## Handles damage and healing requests made against an entity.


# Components
## Keeps reference to the component which handles fall damage calculations.
@export var fall_damage : EntityFallDamage

## Keeps reference to the component which handles death.
@export var death : EntityDeath


# Signals
## Emitted when damage is taken by the entity.
signal damage_taken(amount : float)

## Emitted when health is restored to the entity.
signal health_restored(amount : float)


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	fall_damage.damage_per_velocity = entity.stats.get_max_health()
	death.initialise(entity.state)


# Public Interface
## Processes damage detection for the entity.
func process_damage() -> void:
	update_fall_damage(entity.is_on_floor(), entity.velocity)


## Applies damage to the entity.
func take_damage(amount : float) -> void:
	if amount <= 0.0:
		return
	
	if entity.resource == null or not entity.resource.is_alive():
		return
	
	var previous_health : float = entity.resource.get_health()
	
	entity.resource.take_damage(amount)
	
	var actual_damage : float = previous_health - entity.resource.get_health()
	
	if actual_damage <= 0.0:
		return
	
	damage_taken.emit(actual_damage)
	
	if not entity.resource.is_alive():
		death.down()


## Restores health to the entity.
func heal(amount : float) -> void:
	if amount <= 0.0:
		return
	
	if entity.resource == null or not entity.resource.is_alive():
		return
	
	var previous_health : float = entity.resource.get_health()
	
	entity.resource.heal(amount)
	
	var actual_healing : float = entity.resource.get_health() - previous_health
	
	if actual_healing <= 0.0:
		return
	
	health_restored.emit(actual_healing)


## Updates fall damage detection.
func update_fall_damage(is_on_floor : bool, velocity : Vector3) -> void:
	fall_damage.update(is_on_floor, velocity)
