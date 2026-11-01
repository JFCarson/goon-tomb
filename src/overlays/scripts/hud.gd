class_name HUD
extends Control

## Orchestrator for the player's Heads-up Display.
##
## REFACTOR: This entire class is a temporary placeholder and will need readdressing
## with real assets when available.


# Configuration
## Defines how much the health change flash container's alpha is attenuated by.
const health_feedback_alpha_attenuation : float = 0.35

## Defines how quickly the health flash container fades after showing
const health_feedback_fade_speed : float = 0.5

## Defines the colour of the health flash container when health is reduced.
const damage_feedback_colour : Color = Color(1.0, 0.0, 0.0)

## Defines the colour of the health flash container when health is increased.
const healing_feedback_colour : Color = Color(0.0, 1.0, 0.0)

## Defines how much a bar changes on delta when updating its value.
const bar_speed : float = 100.0


# Components
## Keeps reference to the health bar.
@export var health_bar : ProgressBar

## Keeps reference to the current health label.
@export var current_health_label : Label

## Keeps reference to the max health label.
@export var max_health_label : Label

## Keeps reference to the stamina bar.
@export var stamina_bar : ProgressBar

## Keeps reference to the current stamina label.
@export var current_stamina_label : Label

## Keeps reference to the max stamina label.
@export var max_stamina_label : Label

## Keeps reference to the interact prompt.
@export var interact_prompt : Label

## Keeps reference to the health change flash.
@export var health_change_flash : ColorRect

## Keeps reference to the downed screen.
@export var downed_screen : ColorRect

## Keeps reference to the downed timer label.
@export var downed_timer_label : Label

## Keeps reference to the death screen.
@export var death_screen : ColorRect


# Runtime
## Keeps reference to the overlay controller.
var controller : PlayerOverlayController

## Keeps reference to the currently displayed health value.
var displayed_health : float = 0.0

## Keeps reference to the current health total of the player, and what should
## be displayed by the health bar.
var target_health : float = 0.0

## Keeps reference to the currently displayed stamina value.
var displayed_stamina : float = 0.0

## Keeps reference to the current stamina total of the player, and what should
## be displayed by the stamina bar.
var target_stamina : float = 0.0

## Keeps reference to the current alpha amount of the health change flash.
var health_feedback_alpha : float = 0.0

## Determines whether an instance of current health changing is sourced from
## organic means, such as an attack or heal.
var health_change_is_organic : bool = true


# Process
## Initialise the HUD.
func initialise(overlay_controller : PlayerOverlayController) -> void:
	controller = overlay_controller
	
	_toggle_lifecycle_overlays()
	
	_initialise_resource_bars()
	
	if not controller.entity.stats.health.stat_value_changed.is_connected(_current_health_changed):
		controller.entity.stats.health.stat_value_changed.connect(_current_health_changed)
		
	if not controller.entity.stats.health.base_value_changed.is_connected(_max_health_changed):
		controller.entity.stats.health.base_value_changed.connect(_max_health_changed)
		
	if not controller.entity.stats.stamina.stat_value_changed.is_connected(_current_stamina_changed):
		controller.entity.stats.stamina.stat_value_changed.connect(_current_stamina_changed)
		
	if not controller.entity.stats.stamina.base_value_changed.is_connected(_max_stamina_changed):
		controller.entity.stats.stamina.base_value_changed.connect(_max_stamina_changed)
		
	if not controller.entity.state.state_changed.is_connected(_state_changed):
		controller.entity.state.state_changed.connect(_state_changed)


## Process the movement of resource bars.
func _process(delta : float) -> void:
	displayed_health = move_toward(displayed_health, target_health, bar_speed * delta)
	displayed_stamina = move_toward(displayed_stamina, target_stamina, bar_speed * delta)
	
	_update_health_display()
	_update_stamina_display()
	
	if health_feedback_alpha != 0.0:
		_update_health_feedback(delta)
	
	if controller.player.state.check(EntityStateEnums.States.LIFECYCLE) == EntityStateEnums.Lifecycle.DOWNED:
		downed_timer_label.text = str(snappedf(controller.player.damage.death.get_bleed_out_time(), 0.1))

# Private Methods
## Initialises starting values for resources.
func _initialise_resource_bars() -> void:
	# Health
	displayed_health = controller.entity.stats.health.current
	target_health = displayed_health
	
	health_bar.max_value = controller.entity.stats.health.base
	health_bar.value = displayed_health
	max_health_label.text = str(int(controller.entity.stats.health.base))
	current_health_label.text = str(int(displayed_health))
	
	# Stamina
	displayed_stamina = controller.entity.stats.stamina.current
	target_stamina = displayed_stamina
	
	stamina_bar.max_value = controller.entity.stats.stamina.base
	stamina_bar.value = displayed_stamina
	max_stamina_label.text = str(int(controller.entity.stats.stamina.base))
	current_stamina_label.text = str(int(displayed_stamina))


## Update the current values of the health bar.
func _update_health_display() -> void:
	health_bar.value = displayed_health
	current_health_label.text = str(roundi(displayed_health))


## Update the current values of the stamina bar.
func _update_stamina_display() -> void:
	stamina_bar.value = displayed_stamina
	current_stamina_label.text = str(roundi(displayed_stamina))


## Updates the health change flash.
func _update_health_feedback(delta : float) -> void:
	health_feedback_alpha = move_toward(health_feedback_alpha, 0.0, delta * health_feedback_fade_speed)
	health_change_flash.modulate.a = health_feedback_alpha


## Changes the screen overlays to reflect the current lifecycle state of the 
## player.
func _toggle_lifecycle_overlays() -> void:
	match controller.player.state.check(EntityStateEnums.States.LIFECYCLE):
		EntityStateEnums.Lifecycle.ALIVE:
			downed_screen.visible = false
			death_screen.visible = false
		
		EntityStateEnums.Lifecycle.DOWNED:
			downed_screen.visible = true
			death_screen.visible = false
		
		EntityStateEnums.Lifecycle.DEAD:
			downed_screen.visible = false
			death_screen.visible = true


# Signal Methods
## Update the hud when the player's current health changes.
func _current_health_changed(change_amount : float, new_amount : float) -> void:
	target_health = new_amount
	
	if health_change_is_organic:
		if change_amount > 0.0:
			health_change_flash.color = healing_feedback_colour
		elif change_amount < 0.0:
			health_change_flash.color = damage_feedback_colour
		
		health_feedback_alpha = min(health_feedback_alpha + (absf(change_amount) / controller.player.stats.health.base) * health_feedback_alpha_attenuation, 1.0)
	
	health_change_is_organic = true  # Ensure that this flag is reset for next use.


## Update the hud when the player's max health changes.
func _max_health_changed(_change_amount : float, new_amount : float) -> void:
	health_bar.max_value = new_amount
	max_health_label.text = str(int(new_amount))
	health_change_is_organic = false


## Update the hud when the player's current stamina changes.
func _current_stamina_changed(_change_amount : float, new_amount : float) -> void:
	target_stamina = new_amount


## Update the hud when the player's max stamina changes.
func _max_stamina_changed(_change_amount : float, new_amount : float) -> void:
	stamina_bar.max_value = new_amount
	max_stamina_label.text = str(int(new_amount))


## Enacts a state change onto the HUD.
func _state_changed(state : EntityStateEnums.States, _value : int) -> void:
	match state:
		EntityStateEnums.States.LIFECYCLE:
			_toggle_lifecycle_overlays()
