class_name EntityStatSheet
extends Resource

## Stat sheet to propogate values into an entity.


@export_group("Health")
# Entity's maximum health value.
@export var max_health : float = 100.0


@export_group("Stamina")
# Entity's maximum stamina value.
@export var max_stamina : float = 100.0

# The rate at which the entity spends stamina when sprinting.
@export var sprint_drain_rate : float = 10.0

# The amount of stamina taking the jump action costs.
@export var jump_cost : float = 20.0

# The rate per second at which the entity recovers stamina naturally.
@export var regeneration_rate : float = 10.0

# The delay in seconds before natural stamina regeneration begins.
@export var regeneration_delay : float = 2.0
