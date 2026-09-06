class_name EntityConfig
extends Resource

## A full instance of an entity's config values.

# Sets the entity's collision height in meters when standing.
@export var standing_height : float = 1.8

# Configuration for the entity's state controller.
@export var state : EntityStateConfig

# Configuration for the entity's movement controller.
@export var movement : EntityMovementConfig
