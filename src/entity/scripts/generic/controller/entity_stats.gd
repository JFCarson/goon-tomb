class_name EntityStatsController
extends EntityController

## Configuration
# Reference to the config of the controller.
var attributes : EntityAttributes

var stat_coefficient = 25;

## Health calculations
#Returns max hp value
func get_max_hp() -> float:
	return (stat_coefficient + (config.level * 5) + (attributes.vigour * 5) + (attributes.might * 2.5));
	
func get_heal_efficiency() -> float:
	return (2 * attributes.vigour);

## Stamina calculations
# Entity's maximum stamina value.
func get_max_stamina() -> float:
	return (stat_coefficient + (config.level * 5) + (attributes.finesse * 5) +  (attributes.might * 2.5));

# The rate at which the entity spends stamina when sprinting.
func get_stamina_drain_rate() -> float:
	return (10.0)
# The amount of stamina taking the jump action costs.
func get_jump_cost() -> float:
	return (20);

# The rate per second at which the entity recovers stamina naturally.
func get_regeneration_rate() -> float:
	return (10.0);

# The delay in seconds before natural stamina regeneration begins.
func get_regeneration_delay() -> float:
	return (2.0);
