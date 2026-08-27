class_name HUD
extends Control

@onready var stamina_bar : ProgressBar = $MarginContainer/InfoBars/Stamina/StaminaBar


func update_stamina(current_stamina : float, max_stamina : float) -> void:
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
