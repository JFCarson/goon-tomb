class_name PlayerInteractionController
extends PlayerController

## Handles player interaction detection, prompts and interaction execution.


# Components
## Keeps reference to the player's interact ray.
var interact_ray : RayCast3D

## Keeps reference to the player's HUD prompt label.
var prompt : Label


# Runtime
## Keeps reference to the currently 'selected' Interactable.
var current_target : Interactable = null


# Signals
## Emmitted when a special interaction is triggered.
signal interaction_request(response : InteractionRequest)


# Process
## Intitialise the controller.
func initialise(entity_orchestrator : CharacterEntity) -> void:
	super.initialise(entity_orchestrator)
	
	interact_ray = player.camera.get_interact_ray()
	prompt = player.overlay.hud.get_interact_prompt()


# Public Interface
## Updates the current interaction target and its prompt.
func update_interaction() -> void:
	current_target = _get_target()
	
	if current_target == null:
		prompt.text = ""
	else:
		prompt.text = current_target.get_prompt()


## Attempts to interact with the currently targeted object. If the interaction
## returns a request, rather than finishing the interaction, send a signal
## with the request to be finalised elsewhere.
func try_interact() -> void:
	if current_target == null:
		return
	
	var request : InteractionRequest = current_target.interact()
	
	if request != null:
		if not request.type == InteractableEnums.ResponseType.UNDEFINED:
			interaction_request.emit(request)
			return
	
	finish_interaction(current_target)
	

## Finishes the interaction on an interactable.
func finish_interaction(target : Interactable) -> void:
	target.process_interaction()


# Private Methods
## Returns the interactable currently targeted by the interaction ray.
func _get_target() -> Interactable:
	if interact_ray.is_colliding():
		var collider : Object = interact_ray.get_collider()
		
		if collider is Node:
			for child : Node in collider.get_children():
				if child is Interactable:
					return child
	
	return null
