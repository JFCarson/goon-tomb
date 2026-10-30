class_name EntityResourceController
extends EntityController

## Coordinates the resource components belonging to an entity.

# Config
## Defines how much stamina must change by to report a change.
const STAMINA_SIGNAL_THRESHOLD: float = 1.0


# Components
## Keeps reference to the component which manages state and calculations for the 
## entity's health.
@export var health : EntityHealth

## Keeps reference to the component which manages state and calculations for the
## entity's stamina.
@export var stamina : EntityStamina


# Signals
## Emits when health changes, containing a payload with both current and maximum
## health.
signal health_changed(current_health: float, max_health: float);

## Emits when stamina changes, containing a payload with both current and maximum
## stamina.
signal stamina_changed(current_stamina: float, max_stamina: float);


# Runtime
## Flags whether sprint is locked.
var sprint_locked : bool = false

## Keeps reference to the amount of stamina emitted.
var last_emitted_stamina: float


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	health.setup(entity.stats)
	stamina.setup(entity.stats)
	last_emitted_stamina = stamina.get_stamina()
	
	health.reset()
	stamina.reset()


# Public Interface
## Processes the entity's resource systems.
func process_resources(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	var is_sprinting : bool = action_list.has(EntityEnums.Action.SPRINT)
	update_stamina(delta, is_sprinting)
	
	# REFACTOR: THIS IS ALMOST DEFINITELY IN THE WRONG PLACE
	health_changed.emit(get_health(), get_max_health())


## Resets all resource components to their configured defaults.
func reset() -> void:
	health.reset()
	stamina.reset()
	sprint_locked = false


# Public Interface: Health
## Returns the entity's current health.
func get_health() -> float:
	return health.get_health()


## Returns the entity's maximum health.
func get_max_health() -> float:
	return health.get_max_health()


## Returns whether the entity is currently alive.
func is_alive() -> bool:
	return health.is_alive()


## Returns whether the entity can afford the supplied health cost.
func can_afford_health(cost : float) -> bool:
	return health.can_afford(cost)


## Applies damage to the entity's health.
func take_damage(amount : float) -> void:
	health.take_damage(amount)


## Restores the entity's health.
func heal(amount : float) -> void:
	health.heal(amount)


# Public Interface: Stamina
## Processes updates to the entity's stamina, and the reactions from the updates.
func update_stamina(delta : float, is_sprinting : bool) -> void:
	stamina.update(delta, is_sprinting, entity.state.check(EntityStateEnums.States.MOTION) == EntityStateEnums.Motion.SPRINTING)
	if abs(stamina.get_stamina() - last_emitted_stamina) >= STAMINA_SIGNAL_THRESHOLD:
		stamina_changed.emit(stamina.get_stamina(), stamina.get_max_stamina())
		last_emitted_stamina = stamina.get_stamina()
		
	if not is_sprinting:
		sprint_locked = false
		
	elif not can_afford_sprint():
		sprint_locked = true


## Returns the entity's current stamina.
func get_stamina() -> float:
	return stamina.get_stamina()


## Returns the entity's maximum stamina.
func get_max_stamina() -> float:
	return stamina.get_max_stamina()


## Returns whether the entity currently has enough stamina to sprint.
func can_afford_sprint() -> bool:
	return stamina.can_afford_sprint() and not sprint_locked


## Returns whether the entity has enough stamina to jump.
func can_afford_jump() -> bool:
	return stamina.can_afford_jump()


## Consumes the stamina cost associated with jumping.
func consume_jump() -> bool:
	return stamina.consume_jump()
