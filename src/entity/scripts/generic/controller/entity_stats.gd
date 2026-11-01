class_name EntityStatsController
extends EntityController

## Controller for handling an entity's stats.


# Components
## Keeps reference to the Health stat component.
@export var health : Health

## Keeps reference to the Stamina stat component.
@export var stamina : Stamina

## Keeps reference to the Stamina Regeneration stat component.
@export var stamina_regeneration : StaminaRegeneration


# Config
## Defines the minimum level that an entity can be.
const minimum_level : int = 1

## Defines the maximum level that an entity can be.
const maximum_level : int = 20

## Keeps reference to the entity's attribute sheet.
var attributes : EntityAttributes


# Runtime
## Keeps reference to the entity's current level.
var level : int:
	set(new_level):
		level = clampi(new_level, minimum_level, maximum_level)


# Process
## Initialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	attributes = entity.config.attributes
	
	for component : EntityStat in [health, stamina, stamina_regeneration]:
		component.initialise(self)
