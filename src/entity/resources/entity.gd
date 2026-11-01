class_name EntityConfig
extends Resource

# Represents a full instance of an entity's config values.


## Sets the entity's collision height in meters when standing.
@export var standing_height : float = 1.8

## Entity level for scaling mobs stats, exp gains and difficulty.
@export var level : int = 1;

## Configuration for the entity's state controller.
@export var state : EntityStateConfig

## Configuration for the entity's movement.
@export var movement : EntityMovementConfig

## Stat sheet for an entity's attribute values.
@export var attributes : EntityAttributes
