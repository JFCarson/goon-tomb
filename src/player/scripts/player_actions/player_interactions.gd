class_name PlayerInteractions
extends Node

#This code handles updating the prompt
#detects if the raycast is interacting with an interactable object and returns the Interactable prompt variable within Interactable.gd
func _update_interaction(interact_ray : RayCast3D, prompt : Label) -> void:
	prompt.text = ""
	#early returns if object isn't interactable
	if not interact_ray.is_colliding():
		return
	var collider = interact_ray.get_collider()
	if collider is Interactable:
		#uses the get_prompt funcition in Interactable.gd to get the prompt of the interable object and updates the prompt
		prompt.text = collider.get_prompt()

#This code handles the player pressing interact keybind (default (e))
func _try_interact(interact_ray : RayCast3D) -> void:
	#early returns if object isn't interactable
	if not interact_ray.is_colliding():
		return
	var collider = interact_ray.get_collider()
	if collider is Interactable:
		collider.interact()
