class_name PlayerStaminaSettings
extends Resource

## Configuration for the player's stamina system.
## Defines stamina capacity, consumption rates and regeneration behaviour.


## Maximum amount of stamina the player can store.
@export var max_stamina : float = 100.0

## Amount of stamina consumed per second while sprinting.
@export var sprint_drain_rate : float = 15.0

## Amount of stamina consumed when performing a jump.
@export var jump_cost : float = 20.0

## Amount of stamina restored per second when regenerating.
@export var regeneration_rate : float = 15.0

## Time in seconds after consuming stamina before regeneration begins.
@export var regeneration_delay : float = 1.5
