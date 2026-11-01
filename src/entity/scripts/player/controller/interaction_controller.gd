class_name PlayerInteractionController
extends PlayerController

## Handles player interaction detection, prompts and interaction execution.


# Runtime
## Keeps reference to the currently 'selected' Interactable.
var current_target : Interactable = null


# Public Interface
## Updates the current interaction target and its prompt.
func update_interaction() -> void:
	current_target = _get_target()
	
	if current_target == null:
		player.overlay.hud.interact_prompt.text = ""
	else:
		player.overlay.hud.interact_prompt.text = current_target.get_prompt()


## Attempts to interact with the currently targeted object. 
##
## If the interaction returns a request, rather than finishing the interaction, 
## send a signal with the request to be finalised elsewhere.
func try_interact() -> void:
	if current_target == null:
		return
	
	var request : InteractionRequest = current_target.interact()
	if request != null and not request.type == InteractableEnums.ResponseType.UNDEFINED:
		_handle_special_request(request)
		return
	
	finish_interaction(current_target)
	

## Finishes the interaction on an interactable.
func finish_interaction(target : Interactable) -> void:
	target.process_interaction()


# Private Methods
## Returns the interactable currently targeted by the interaction ray.
func _get_target() -> Interactable:
	if player.camera.interact_ray.is_colliding():
		var collider : Object = player.camera.interact_ray.get_collider()
		
		if collider is Node:
			for child : Node in collider.get_children():
				if child is Interactable:
					return child
	
	return null


## Handles a special request.
func _handle_special_request(request : InteractionRequest) -> void:
	if request is PickUpItemRequest:
		if player.inventory.add_item(request.item, request.amount):
			player.interaction.finish_interaction(request.ref)
