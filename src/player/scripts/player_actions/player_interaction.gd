class_name PlayerInteraction
extends Node

## Handles interaction detection, prompts and interaction execution.


# Node References
var interact_ray : RayCast3D
var prompt : Label


## Public Interface
# Initialises the interaction component with its required references.
func initialise(ray : RayCast3D, interaction_prompt : Label) -> void:
	interact_ray = ray
	prompt = interaction_prompt


# Updates the interaction prompt based on the object currently targeted.
func update_interaction() -> void:
	prompt.text = ""

	if not interact_ray.is_colliding():
		return

	var collider = interact_ray.get_collider()

	if collider is Interactable:
		prompt.text = collider.get_prompt()


# Attempts to interact with the object currently targeted.
func try_interact() -> void:
	if not interact_ray.is_colliding():
		return

	var collider = interact_ray.get_collider()

	if collider is Interactable:
		collider.interact()
