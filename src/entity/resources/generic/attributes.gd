class_name EntityAttributes
extends Resource
## Stat sheet to propogate values into an entity.
# Entity base stats.
@export_group("Attributes")
@export var might: int = 1;
@export var finesse : int = 1;
@export var vigour: int = 1;
@export var lore: int = 1;
@export var spirit: int = 1;
@export var presence: int = 1;

#Default values for structural player requirements.
@export_group("Default Values")
@export var stamina_drain_rate: float = 10.0
@export var jump_cost: float = 20.0
@export var stamina_regeneration_rate : float = 10.0
@export var stamina_regeneration_delay: float = 2.0
