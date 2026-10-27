class_name EntityStatsController
extends EntityController


# Runtime
var attributes := EntityAttributes.new()
var stat_coefficient = 75;
var level : int


# Process
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	level = entity.config.level


# Health calculations
func get_max_health() -> float:
	return (stat_coefficient + (level * 5) + (attributes.vigour * 5) + (attributes.might * 2.5))


func get_heal_efficiency() -> float:
	return (2 * attributes.vigour);


# Stamina calculations
## Entity's maximum stamina value.
func get_max_stamina() -> float:
	return (stat_coefficient + (level * 5) + (attributes.finesse * 5) +  (attributes.might * 2.5))


# Entity baselines
## The rate at which the entity spends stamina when sprinting.
func get_sprint_drain_rate() -> float:
	return (attributes.stamina_drain_rate)


# The amount of stamina taking the jump action costs.
func get_jump_cost() -> float:
	return (attributes.jump_cost);


# The rate per second at which the entity recovers stamina naturally.
func get_regeneration_rate() -> float:
	return (attributes.stamina_regeneration_rate)


# The delay in seconds before natural stamina regeneration begins.
func get_regeneration_delay() -> float:
	return (attributes.stamina_regeneration_delay)
