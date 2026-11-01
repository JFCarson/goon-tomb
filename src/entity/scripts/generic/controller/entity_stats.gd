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
## Keeps reference to the entity's attribute sheet.
var attributes : EntityAttributes


# Process
## Initialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	attributes = entity.config.attributes
	
	for component : EntityStat in [health, stamina, stamina_regeneration]:
		component.initialise(self)
