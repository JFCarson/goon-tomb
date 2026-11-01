class_name EntityFallDamage
extends EntityComponent

## Calculates fall damage based on the distance an entity falls.


# Configuration
@export var minimum_fall_distance : float = 3.0
@export var maximum_fall_distance : float = 10.0


# Runtime
## Records the starting height of a fall.
var fall_start_height : float = 0.0

## Records the landing height of a fall.
var fall_landing_height : float = 0.0

## Determines whether the entity is currently falling.
var is_falling : bool = false

## Determines whether a fall has been completed and is awaiting damage processing.
var fall_completed : bool = false


# Public Interface
## Calculates damage from the completed fall.
func calculate_damage() -> float:
	_physics_update()
	
	if not fall_completed:
		return 0.0
	
	var fall_distance : float = fall_start_height - fall_landing_height
	
	fall_completed = false
	
	if fall_distance < minimum_fall_distance:
		return 0.0
		
	var fall_percentage : float = clampf((fall_distance - minimum_fall_distance) / (maximum_fall_distance - minimum_fall_distance), 0.0, 1.0)
	
	return (controller.entity.stats.health.base * fall_percentage)


# Private Methods
## Detects the beginning and end of falls.
func _physics_update() -> void:
	var grounded : bool = controller.entity.is_on_floor()
	if not grounded and not is_falling:
		_start_fall(controller.entity.global_position.y)
		
	elif grounded and is_falling:
		_land(controller.entity.global_position.y)


## Records the starting height of a fall.
func _start_fall(height : float) -> void:
	fall_start_height = height
	is_falling = true
	fall_completed = false


## Records the landing height and completes the fall.
func _land(height : float) -> void:
	fall_landing_height = height
	is_falling = false
	fall_completed = true
