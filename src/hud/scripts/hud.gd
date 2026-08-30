class_name HUD
extends Control


@export var bar_speed : float = 100.0

@onready var stamina_bar : ProgressBar = $MarginContainer/InfoBars/Stamina/StaminaBar
@onready var interact_prompt : Label = $InteractPrompt


var stamina_bar_initialized : bool = false
var displayed_stamina : float = 0.0
var target_stamina : float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta : float) -> void:
	if not stamina_bar_initialized:
		return
	
	displayed_stamina = move_toward(displayed_stamina, target_stamina, bar_speed * delta)
	
	stamina_bar.value = displayed_stamina


func update_stamina(current_stamina : float, max_stamina : float) -> void:
	target_stamina = current_stamina
	
	if not stamina_bar_initialized:
		displayed_stamina = current_stamina
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina
		stamina_bar_initialized = true


func get_interact_prompt() -> Label:
	return interact_prompt
