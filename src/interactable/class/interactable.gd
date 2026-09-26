class_name Interactable
extends PhysicsBody3D

## Base class for all interactable objects, such as items, doors, and NPCs.


## Configuration
const prompt_action : StringName = &"interact"

var prompt_message : String = "Interact"


## Public Interface
# Returns the interaction prompt displayed to the player.
func get_prompt() -> String:
	var key_name : String = ""
	for event : InputEvent in InputMap.action_get_events(prompt_action):
		if event is InputEventKey:
			if event.physical_keycode != 0:
				key_name = OS.get_keycode_string(event.physical_keycode)
			elif event.keycode != 0:
				key_name = OS.get_keycode_string(event.keycode)
			
	return "%s\n[%s]" % [prompt_message, key_name]


# Entry point API method to interact with the instance.
func interact() -> InteractionRequest:
	return _create_interaction_request()


# Processes a previously validated interaction. Passes by default; behaviour
# needs to be defined at the subclass level.
func process_interaction() -> void:
	pass


## Private Methods
# Provides a hook for a subclass to create an interaction request, which is
# returned to whatever called the interact() method.
func _create_interaction_request() -> InteractionRequest:
	return null
