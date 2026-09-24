class_name Interaction
extends Node

## Handles player interaction detection, prompts and interaction execution.


## Components
var interact_ray : RayCast3D
var prompt : Label


## Runtime State
var current_target : Interactable = null


## Mapping
# Maps interaction response types to private methods.
var response_map : Dictionary[InteractableEnums.ResponseType, Callable] = {
	InteractableEnums.ResponseType.PICK_UP: _handle_pick_up_item
}


## Public Interface
# Updates the current interaction target and its prompt.
func update_interaction() -> void:
	current_target = _get_target()
	
	if current_target == null:
		prompt.text = ""
	else:
		prompt.text = current_target.get_prompt()


# Attempts to interact with the currently targeted object.
func try_interact() -> void:
	if current_target == null:
		return
	
	var interaction_is_valid : bool = true
	
	var response : InteractionResponse = current_target.interact()
	
	if response != null:
		if not response.type == InteractableEnums.ResponseType.UNDEFINED:
			interaction_is_valid = response_map[response.type].call(response)
	
	if interaction_is_valid:
		current_target.process_interaction()


## Private Methods
# Returns the interactable currently targeted by the interaction ray.
func _get_target() -> Interactable:
	if interact_ray.is_colliding():
		var collider : Object = interact_ray.get_collider()
		
		if collider is Interactable:
			return collider
	
	return null


## Private Methods: Interaction Responses
# Handles a pick up item response.
func _handle_pick_up_item(interaction_response : PickUpItemResponse) -> bool:
	var interaction_is_valid : bool = true
	
	print("Picked up a %s." % interaction_response.data.name)
	
	return interaction_is_valid


## Validation
func _validate() -> void:
	assert(interact_ray != null, "Interaction requires a RayCast3D.")
	assert(prompt != null, "Interaction requires an interaction prompt Label.")
