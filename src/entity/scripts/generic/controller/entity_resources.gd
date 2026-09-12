class_name EntityResourceController
extends EntityController

## Coordinates the resource components belonging to an entity.


## Components
@onready var health : EntityHealth = $EntityHealth
@onready var stamina : EntityStamina = $EntityStamina


## Runtime State
var sprint_locked : bool = false


func _initialise_hook() -> void:
	health.stat_sheet = config.stats
	stamina.stat_sheet = config.stats
	
	_validate_components()
	
	health.reset()
	stamina.reset()


## Public Interface
# Updates all resource components for the current frame.
func update(delta : float, is_sprinting : bool) -> void:
	stamina.update(delta, is_sprinting)
	
	if not is_sprinting:
		sprint_locked = false
	elif not stamina.can_sprint():
		sprint_locked = true


# Resets all resource components to their configured defaults.
func reset() -> void:
	health.reset()
	stamina.reset()
	sprint_locked = false


## Public Interface: Health
# Returns the entity's current health.
func get_health() -> float:
	return health.get_health()


# Returns the entity's maximum health.
func get_max_health() -> float:
	return health.get_max_health()


# Returns whether the entity is currently alive.
func is_alive() -> bool:
	return health.is_alive()


# Returns whether the entity can afford the supplied health cost.
func can_afford_health(cost : float) -> bool:
	return health.can_afford(cost)


# Applies damage to the entity's health.
func take_damage(amount : float) -> void:
	health.take_damage(amount)


# Restores the entity's health.
func heal(amount : float) -> void:
	health.heal(amount)


## Public Interface: Stamina
# Returns the entity's current stamina.
func get_stamina() -> float:
	return stamina.get_stamina()


# Returns the entity's maximum stamina.
func get_max_stamina() -> float:
	return stamina.get_max_stamina()


# Returns whether the entity currently has enough stamina to sprint.
func can_sprint() -> bool:
	return stamina.can_sprint() and not sprint_locked


# Returns whether the entity has enough stamina to jump.
func can_jump() -> bool:
	return stamina.can_jump()


# Consumes the stamina cost associated with jumping.
func consume_jump() -> bool:
	return stamina.consume_jump()


## Validation
func _validate() -> void:
	assert(health != null, "EntityResourceController requires an EntityHealth component.")
	assert(stamina != null, "EntityResourceController requires an EntityStamina component.")
	assert(config.stats != null, "EntityResourceController requires an EntityStatSheet.")
	
	_validate_components()


func _validate_components() -> void:
	health.validate()
	stamina.validate()
