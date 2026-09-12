class_name CameraDamageFeedback
extends Node

## Calculates temporary camera rotation caused by damage events.


## Configuration
var config : PlayerConfig


## Runtime State
var damage_feedback_rotation : float = 0.0
var target_damage_feedback_rotation : float = 0.0
var feedback_strength : float = 0.0


## Public Interface
# Updates the damage feedback rotation for the current frame.
func update(delta : float) -> float:
	var speed_multiplier : float = lerp(1.0, config.camera.damage_feedback_max_speed_multiplier, feedback_strength)
	var damage_feedback_speed : float = config.camera.damage_feedback_decay_speed * speed_multiplier
	
	if target_damage_feedback_rotation > damage_feedback_rotation:
		damage_feedback_speed = config.camera.damage_feedback_build_speed * speed_multiplier
	
	damage_feedback_rotation = move_toward(damage_feedback_rotation, target_damage_feedback_rotation, damage_feedback_speed * delta)
	target_damage_feedback_rotation = move_toward(target_damage_feedback_rotation, 0.0, config.camera.damage_feedback_decay_speed * speed_multiplier * delta)
	feedback_strength = move_toward(feedback_strength, 0.0, delta)
	
	return damage_feedback_rotation


# Applies a temporary camera rotation in response to a damage event.
func feedback(magnitude : float) -> void:
	magnitude = clamp(magnitude, 0.0, 1.0)
	
	var minimum_rotation : float = deg_to_rad(config.camera.damage_feedback_min_rotation)
	var maximum_rotation : float = deg_to_rad(config.camera.damage_feedback_max_rotation)
	var feedback_rotation : float = lerp(minimum_rotation, maximum_rotation, magnitude)
	
	target_damage_feedback_rotation = min(target_damage_feedback_rotation + feedback_rotation, maximum_rotation)
	feedback_strength = max(feedback_strength, magnitude)


# Resets the damage feedback to its neutral state.
func reset() -> void:
	damage_feedback_rotation = 0.0
	target_damage_feedback_rotation = 0.0
	feedback_strength = 0.0


## Validation
func validate() -> void:
	assert(config != null, "CameraDamageFeedback requires a PlayerConfig.")
	assert(config.camera != null, "CameraDamageFeedback requires a PlayerCameraConfig.")
	assert(config.camera.damage_feedback_min_rotation >= 0.0, "CameraDamageFeedback requires damage_feedback_min_rotation to be zero or greater.")
	assert(config.camera.damage_feedback_max_rotation >= config.camera.damage_feedback_min_rotation, "CameraDamageFeedback requires damage_feedback_max_rotation to be greater than or equal to damage_feedback_min_rotation.")
	assert(config.camera.damage_feedback_build_speed > 0.0, "CameraDamageFeedback requires damage_feedback_build_speed to be greater than zero.")
	assert(config.camera.damage_feedback_decay_speed > 0.0, "CameraDamageFeedback requires damage_feedback_decay_speed to be greater than zero.")
	assert(config.camera.damage_feedback_max_speed_multiplier >= 1.0, "CameraDamageFeedback requires damage_feedback_max_speed_multiplier to be one or greater.")
