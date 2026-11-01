class_name EntityDeath
extends EntityComponent

## Handles lifecycle behaviour caused by damage and other gameplay events.
## The current lifecycle value is stored by EntityStateController.


# Configuration
## Flags whether an entity can be downed, or just immediately dies.
@export var downed_enabled : bool = false

## Defines how long it takes to bleed out if downed.
@export var bleed_out_duration : float = 30.0


# Runtime
## Timer used to track how long an entity has before bleeding out.
@onready var bleed_out_timer : Timer


# Process
## Configure the bleed out timer if enabled.
func _ready() -> void:
	if downed_enabled:
		bleed_out_timer = Timer.new()
		bleed_out_timer.one_shot = true
		bleed_out_timer.timeout.connect(bleed_out)
		
		add_child(bleed_out_timer)


## Initialises the component.
func initialise(controller_component : EntityController) -> void:
	super.initialise(controller_component)
	
	controller.entity.stats.health.stat_value_changed.connect(_entity_health_changed)


# Public Interface
## Transitions the entity into the downed state.
func down() -> void:
	if controller.entity.state.check(EntityStateEnums.States.LIFECYCLE) != EntityStateEnums.Lifecycle.ALIVE:
		return
		
	if not downed_enabled:
		die()
	else:
		controller.entity.state.update(EntityStateEnums.States.LIFECYCLE, EntityStateEnums.Lifecycle.DOWNED)
		bleed_out_timer.start(bleed_out_duration)


## Transitions the entity into the dead state.
func die() -> void:
	if controller.entity.state.check(EntityStateEnums.States.LIFECYCLE) == EntityStateEnums.Lifecycle.DEAD:
		return
		
	bleed_out_timer.stop()
	controller.entity.state.update(EntityStateEnums.States.LIFECYCLE, EntityStateEnums.Lifecycle.DEAD)


## Recovers the entity from the downed state.
func recover() -> void:
	if controller.entity.state.check(EntityStateEnums.States.LIFECYCLE) != EntityStateEnums.Lifecycle.DOWNED:
		return
		
	bleed_out_timer.stop()
	controller.entity.state.update(EntityStateEnums.States.LIFECYCLE, EntityStateEnums.Lifecycle.ALIVE)


## Transitions a downed entity into the dead state.
func bleed_out() -> void:
	if controller.entity.state.check(EntityStateEnums.States.LIFECYCLE) == EntityStateEnums.Lifecycle.DOWNED:
		die()


## Resets the entity to its initial alive state.
func reset() -> void:
	bleed_out_timer.stop()
	controller.entity.state.update(EntityStateEnums.States.LIFECYCLE, EntityStateEnums.Lifecycle.ALIVE)


## Returns the remaining bleed-out time.
func get_bleed_out_time() -> float:
	return bleed_out_timer.time_left


# Signal Methods
## Figures out if the entity has died.
func _entity_health_changed(_change_amount : float, new_amount : float) -> void:
	if new_amount == controller.entity.stats.health.min_value:
		down()
