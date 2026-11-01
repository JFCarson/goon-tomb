@tool
class_name StaminaRegeneration
extends EntityStat

## Manages an entity's stamina regeneration, and provides an API to manipulate it.


# Config
## Defines the interval between stamina regeneration instances.
const regeneration_interval : float = 0.1


# Runtime
## Timer used to keep track of the delay before stamina begins to regenerate.
@onready var regeneration_delay_timer : Timer = Timer.new() 

## Timer used to process gradual regeneration of stamina.
@onready var regeneration_timer : Timer = Timer.new()


# Process
## Initialises the stat for the entity.
func initialise(controller_component : EntityController) -> void:
	super.initialise(controller_component)
	
	regeneration_delay_timer.one_shot = true
	regeneration_timer.one_shot = false
	
	regeneration_delay_timer.timeout.connect(_on_regeneration_delay_timeout)
	regeneration_timer.timeout.connect(_on_regeneration_timeout)
	
	add_child(regeneration_delay_timer)
	add_child(regeneration_timer)

# Public Interface
## Restarts the regeneration delay timer, and stops active regeneration.
func restart_delay_timer() -> void:
	regeneration_timer.stop()
	regeneration_delay_timer.start(stats_controller.attributes.stamina_regeneration_delay)


# Signal Methods
## Starts the regeneration timer once the delay timer times out.
func _on_regeneration_delay_timeout() -> void:
	regeneration_timer.start(regeneration_interval)


## Restores the current amount of stamina on each tick, assuming the regeneration
## timer is looping.
func _on_regeneration_timeout() -> void:
	if stats_controller.stamina.current >= stats_controller.stamina.base:
		regeneration_timer.stop()
		return

	stats_controller.stamina.current += current
