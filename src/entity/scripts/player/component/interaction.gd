class_name Interaction
extends Node

## Handles player interaction detection, prompts and interaction execution.


## Components
var interact_ray : RayCast3D
var prompt : Label


## Runtime State
var current_target : Interactable = null


## Public Interface
# Updates the current interaction target and its prompt.
func update_interaction() -> void:
	current_target = _get_target()
	
	prompt.text = ""
	
	if current_target == null:
		return
	
	prompt.text = current_target.get_prompt()


# Attempts to interact with the currently targeted object.
func try_interact() -> void:
	if current_target == null:
		return
	
	current_target.interact()


## Private Methods
# Returns the interactable currently targeted by the interaction ray.
func _get_target() -> Interactable:
	if not interact_ray.is_colliding():
		return null
	
	var collider : Object = interact_ray.get_collider()
	
	if collider is Interactable:
		return collider
	
	return null


## Validation
func _validate() -> void:
	assert(interact_ray != null, "Interaction requires a RayCast3D.")
	assert(prompt != null, "Interaction requires an interaction prompt Label.")
