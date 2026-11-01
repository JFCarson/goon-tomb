class_name EntityAttributes
extends Resource

## Stat sheet to propogate values into an entity.


# Base Attributes
@export_group("Attributes")
## Keeps reference to the entity's Might stat value.
@export var might: int = 0;

## Keeps reference to the entity's Finesse stat value.
@export var finesse : int = 0;

## Keeps reference to the entity's Vigour stat value.
@export var vigour: int = 0;

## Keeps reference to the entity's Lore stat value.
@export var lore: int = 0;

## Keeps reference to the entity's Spirit stat value.
@export var spirit: int = 0;

## Keeps reference to the entity's Presence stat value.
@export var presence: int = 0;


# Special Attributes - Manipulated Separately from Base Attributes
@export_group("Special Attributes")
## Keeps reference to the time it takes before the entity begins to recover its
## stamina.
@export var stamina_regeneration_delay: float = 2.0
