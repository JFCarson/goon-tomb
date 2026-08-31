class_name HUD
extends Control


const HEALTH_FEEDBACK_ATTENUATION : float = 0.3
const HEALTH_FEEDBACK_FADE_SPEED : float = 0.15
const DAMAGE_FEEDBACK_COLOUR : Color = Color(1.0, 0.0, 0.0)
const HEALING_FEEDBACK_COLOUR : Color = Color(0.0, 1.0, 0.0)


@export var bar_speed : float = 100.0

@onready var health_bar : ProgressBar = $MarginContainer/InfoBars/Health/HealthBar
@onready var stamina_bar : ProgressBar = $MarginContainer/InfoBars/Stamina/StaminaBar
@onready var interact_prompt : Label = $InteractPrompt
@onready var health_change_rect : ColorRect = $HealthChangeFlash


var health_feedback_alpha : float = 0.0


var displayed_health : float = 0.0
var target_health : float = 0.0

var displayed_stamina : float = 0.0
var target_stamina : float = 0.0


func _process(delta : float) -> void:
	displayed_health = move_toward(displayed_health, target_health, bar_speed * delta)
	displayed_stamina = move_toward(displayed_stamina, target_stamina, bar_speed * delta)
	
	health_bar.value = displayed_health
	stamina_bar.value = displayed_stamina
	
	health_feedback_alpha = move_toward(health_feedback_alpha, 0.0, delta * HEALTH_FEEDBACK_FADE_SPEED)
	health_change_rect.modulate.a = health_feedback_alpha


func initialise(max_health : float, max_stamina : float) -> void:
	displayed_health = max_health
	target_health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health
	
	displayed_stamina = max_stamina
	target_stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = max_stamina


func update_health(current_health : float) -> void:
	target_health = current_health


func update_stamina(current_stamina : float) -> void:
	target_stamina = current_stamina


func get_interact_prompt() -> Label:
	return interact_prompt


# Displays health feedback using the supplied colour and magnitude.
func health_feedback(magnitude : float, colour : Color) -> void:
	health_change_rect.color = colour
	health_feedback_alpha = min(health_feedback_alpha + magnitude * HEALTH_FEEDBACK_ATTENUATION, 1.0)
