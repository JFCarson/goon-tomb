@tool @abstract
class_name EntityStat
extends EntityComponent

## Base class for tracking and manipulating a stat for an entity.


# Config
## Keeps reference to the stats controller of the managed entity.
var stats_controller : EntityStatsController:
	set(controller):
		stats_controller = controller as EntityStatsController

## Sets the starting amount for this stat.
@export var starting_amount : float = 0.0


@export_category("Minimum/Maximum Values")
## Determines if the stat has value clamping.
@export var clamp_values : bool = false:
	set(value):
		clamp_values = value
		notify_property_list_changed()
		_reclamp_current()

## Determines whether the base value represents the maximum value.
@export var base_is_maximum : bool = false:
	set(value):
		base_is_maximum = value
		notify_property_list_changed()
		_reclamp_current()

## Defines the stat's minumum value.
@export var min_value : float = 0.0:
	set(value):
		min_value = value
		_reclamp_current()

## Defines the stat's maximum value.
@export var max_value : float = 0.0:
	set(value):
		max_value = value
		_reclamp_current()


## Defines the amount that the stat is modified by various factors.
@export_category("Stat Multipliers")
## Defines the amount that the entity's level effects this stat.
@export var level_multiplier : float = 0.0

## Defines the amount that the Might attribute effects this stat.
@export var might_multiplier : float = 0.0 

## Defines the amount that the Finesse attribute effects this stat.
@export var finesse_multiplier : float = 0.0 

## Defines the amount that the Vigour attribute effects this stat.
@export var vigour_multiplier : float = 0.0 

## Defines the amount that the Lore attribute effects this stat.
@export var lore_multiplier : float = 0.0 

## Defines the amount that the Spirit attribute effects this stat.
@export var spirit_multiplier : float = 0.0 

## Defines the amount that the Presence attribute effects this stat.
@export var presence_multiplier : float = 0.0 


# Signals
## Emitted when the current stat value has changed.
signal stat_value_changed(change_amount : float, new_amount : float)

## Emitted when the base stat value has changed.
signal base_value_changed(change_amount : float, new_amount : float)


# Process
## Initialises the stat for the entity.
func initialise(controller_component : EntityController) -> void:
	super.initialise(controller_component)
	
	assert(controller is EntityStatsController, "EntityStat components must be a child of an EntityStatsController.")
	stats_controller = controller
	
	base = 0.0
	current = base


# Runtime
## Keeps track of the current value of the stat.
var current : float:
	set(value):
		var starting_value : float = current
		var new_value : float
		
		if clamp_values:
			new_value = clampf(value, min_value, base if base_is_maximum else max_value)
		else:
			new_value = value
			
		var difference : float = new_value - starting_value
		if difference != 0:
			current = new_value
			stat_value_changed.emit(difference, current)


## Keeps track of the base value of the stat.
##
## To set this value correctly, pass in the raw amount of stats that are being
## applied to the entity, without modification from the likes of level,
## coefficient, etc..
var base : float:
	set(raw_value):
		var calculated_value : float = _calculate_base_value() + raw_value
		var starting_value : float = base
		var new_value : float
		
		if clamp_values:
			if base_is_maximum:
				new_value = maxf(calculated_value, min_value)
			else:
				new_value = clampf(calculated_value, min_value, max_value)
		else:
			new_value = calculated_value
		
		var difference : float = new_value - starting_value
		if difference != 0:
			base = new_value
			base_value_changed.emit(difference, base)
			
			if clamp_values and base_is_maximum:
				current = current


# Public Methods
## Set the current value to its base.
func reset() -> void:
	current = base


## Returns whether the entity has at least a specified amount of the stat.
func has_at_least(amount : float) -> bool:
	return current >= amount


# Private Methods
## Calculates the base value for the stat.
func _calculate_base_value() -> float:
	return (
		starting_amount
		+ (stats_controller.level * level_multiplier)
		+ (stats_controller.attributes.might * might_multiplier)
		+ (stats_controller.attributes.finesse * finesse_multiplier)
		+ (stats_controller.attributes.vigour * vigour_multiplier)
		+ (stats_controller.attributes.lore * lore_multiplier)
		+ (stats_controller.attributes.spirit * spirit_multiplier)
		+ (stats_controller.attributes.presence * presence_multiplier)
	)


## Update the inspector visibility of the clamp values if the bool is toggled.
func _validate_property(property : Dictionary) -> void:
	match property.name:
		&"min_value":
			if not clamp_values:
				property.usage = PROPERTY_USAGE_NO_EDITOR
				
		&"base_is_maximum":
			if not clamp_values:
				property.usage = PROPERTY_USAGE_NO_EDITOR
				
		&"max_value":
			if not clamp_values or base_is_maximum:
				property.usage = PROPERTY_USAGE_NO_EDITOR


## Reclamps the current value if clamp_values is toggled on.
func _reclamp_current() -> void:
	if clamp_values:
		current = current
