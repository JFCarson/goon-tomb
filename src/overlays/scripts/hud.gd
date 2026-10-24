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

var resource_controller: EntityResourceController
var damage_controller: EntityDamageController
var state_controller: EntityStateController

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
func initialise(resource_controller_ref: EntityResourceController, damage_controller_ref: EntityDamageController, state_controller_ref: EntityStateController) -> void:
	resource_controller = resource_controller_ref
	damage_controller = damage_controller_ref
	state_controller = state_controller_ref
	
	_connect_resource_signals(resource_controller)
	_connect_damage_controller(damage_controller)
	_connect_state_controller(state_controller)
	
	displayed_health = resource_controller.get_max_health()
	target_health = resource_controller.get_max_health()
	health_bar.max_value = resource_controller.get_max_health()
	health_bar.value = resource_controller.get_max_health()

	displayed_stamina = resource_controller.get_max_stamina()
	target_stamina = resource_controller.get_max_stamina()
	stamina_bar.max_value = resource_controller.get_max_stamina()
	stamina_bar.value = resource_controller.get_max_stamina()

	update_lifecycle(EntityStateEnums.Lifecycle.ALIVE)
	reset_feedback()

# Private controllers for signal connections
func _connect_resource_signals(resource_controller : EntityResourceController) -> void:
	if not resource_controller.health_changed.is_connected(_on_health_changed):
		resource_controller.health_changed.connect(_on_health_changed)
	if not resource_controller.stamina_changed.is_connected(_on_stamina_changed):
		resource_controller.stamina_changed.connect(_on_stamina_changed)

func _connect_state_controller(state_controller: EntityStateController) -> void:
	if not state_controller.state_changed.is_connected(on_state_changed):
		state_controller.state_changed.connect(on_state_changed)

func _connect_damage_controller(damage_controller: EntityDamageController) -> void:
	if not damage_controller.damage_taken.is_connected(_on_damage_taken):
		damage_controller.damage_taken.connect(_on_damage_taken)
	if not damage_controller.health_restored.is_connected(_on_health_restored):
		damage_controller.health_restored.connect(_on_health_restored)

# Private Functions for changing health, stamina and state
func _on_health_changed(current_health: float, maximum_health: float) -> void:
	target_health = current_health
	health_bar.max_value = maximum_health

# Updates the target stamina value displayed by the HUD.
func _on_stamina_changed(current_stamina : float, maximum_stamina: float) -> void:
	target_stamina = current_stamina
	stamina_bar.max_value = maximum_stamina

# Updates the target health value when damage taken displayed by the hud
func _on_damage_taken(amount: float) -> void:
	var max_health: float = resource_controller.get_max_health()
	if max_health <= 0.0:
		return
	var magnitude: float = amount / max_health
	health_feedback(magnitude, DAMAGE_FEEDBACK_COLOUR)

# Updates the target's health value when health is restored. Displayed by the hud
func _on_health_restored(amount: float) -> void:
	var max_health: float = resource_controller.get_max_health()
	if max_health <= 0.0:
		return
	var magnitude: float = amount / max_health
	health_feedback(magnitude, HEALING_FEEDBACK_COLOUR)

# Public Interface
func on_state_changed(
	target_state: EntityStateEnums.States,
	value: int
) -> void:
	if target_state == EntityStateEnums.States.LIFECYCLE:
		update_lifecycle(value)

# Updates the HUD presentation to reflect the entity's lifecycle state.
func update_lifecycle(lifecycle_state : EntityStateEnums.Lifecycle) -> void:
	match lifecycle_state:
		EntityStateEnums.Lifecycle.ALIVE:
			downed_screen.visible = false
			death_screen.visible = false
		
		EntityStateEnums.Lifecycle.DOWNED:
			downed_screen.visible = true
			death_screen.visible = false
		
		EntityStateEnums.Lifecycle.DEAD:
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
