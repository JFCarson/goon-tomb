class_name HUD
extends Control


# Feedback Configuration
const HEALTH_FEEDBACK_ATTENUATION : float = 0.3
const HEALTH_FEEDBACK_FADE_SPEED : float = 0.15
const DAMAGE_FEEDBACK_COLOUR : Color = Color(1.0, 0.0, 0.0)
const HEALING_FEEDBACK_COLOUR : Color = Color(0.0, 1.0, 0.0)


# Display Configuration
@export var bar_speed : float = 100.0


# UI References: Resource Display
@onready var health_bar : ProgressBar = $MarginContainer/InfoBars/Health/HealthBar
@onready var stamina_bar : ProgressBar = $MarginContainer/InfoBars/Stamina/StaminaBar


# UI References: Interaction
@onready var interact_prompt : Label = $InteractPrompt


# UI References: Lifecycle & Feedback
@onready var health_change_rect : ColorRect = $HealthChangeFlash
@onready var downed_screen : Control = $DownedScreen
@onready var death_screen : Control = $DeathScreen


# Runtime Display State
var displayed_health : float = 0.0
var target_health : float = 0.0

var displayed_stamina : float = 0.0
var target_stamina : float = 0.0

var health_feedback_alpha : float = 0.0


# Updates animated HUD elements independently of the player's simulation.
func _process(delta : float) -> void:
	_update_resource_bars(delta)
	_update_health_feedback(delta)


# Initialises the HUD with the player's maximum resource values.
func initialise(max_health : float, max_stamina : float) -> void:
	displayed_health = max_health
	target_health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health
	
	displayed_stamina = max_stamina
	target_stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = max_stamina
	
	reset_feedback()


## Public Interface
# Updates the target health value displayed by the HUD.
func update_health(current_health : float) -> void:
	target_health = current_health


# Updates the target stamina value displayed by the HUD.
func update_stamina(current_stamina : float) -> void:
	target_stamina = current_stamina


# Updates the HUD presentation to reflect the player's lifecycle state.
func update_lifecycle(lifecycle_state : PlayerEnums.LifecycleState) -> void:
	match lifecycle_state:
		PlayerEnums.LifecycleState.ALIVE:
			downed_screen.visible = false
			death_screen.visible = false
		
		PlayerEnums.LifecycleState.DOWNED:
			downed_screen.visible = true
			death_screen.visible = false
		
		PlayerEnums.LifecycleState.DEAD:
			downed_screen.visible = false
			death_screen.visible = true


# Returns the interaction prompt used by the player input controller.
func get_interact_prompt() -> Label:
	return interact_prompt


# Displays health-related feedback using the supplied colour and magnitude.
func health_feedback(magnitude : float, colour : Color) -> void:
	magnitude = clamp(magnitude, 0.0, 1.0)
	
	health_change_rect.color = colour
	health_feedback_alpha = min(health_feedback_alpha + magnitude * HEALTH_FEEDBACK_ATTENUATION, 1.0)


# Clears any active health feedback.
func reset_feedback() -> void:
	health_feedback_alpha = 0.0
	health_change_rect.modulate.a = 0.0


# Updates the displayed health and stamina bars towards their target values.
func _update_resource_bars(delta : float) -> void:
	displayed_health = move_toward(displayed_health, target_health, bar_speed * delta)
	displayed_stamina = move_toward(displayed_stamina, target_stamina, bar_speed * delta)
	
	health_bar.value = displayed_health
	stamina_bar.value = displayed_stamina


# Fades the active health feedback effect back towards transparency.
func _update_health_feedback(delta : float) -> void:
	health_feedback_alpha = move_toward(health_feedback_alpha, 0.0, delta * HEALTH_FEEDBACK_FADE_SPEED)
	health_change_rect.modulate.a = health_feedback_alpha
