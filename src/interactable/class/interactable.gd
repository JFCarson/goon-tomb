class_name Interactable
extends Node

## Marker class for all interactable objects, such as items, doors, and NPCs.
##
## To integrate this class in a composition, override the 'process' variable in
## the parent, and optionally the 'request' and 'prompt_message' variables if
## required.


## Configuration
# Stores reference to the name of the interact input.
const prompt_action : StringName = &"interact"

# Determines the message that is displayed on screen when the interaction
# RayCast is colliding with the object.
var prompt_message : String = "Interact"

# Callables for each stage of the interaction process. These should be provided
# from the parent.
var request : Callable
var process : Callable


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


# Sets the process callable to reference the passed-in method.
func set_process_callback(callback : Callable) -> void:
	process = callback


# Sets the request callable to reference the passed-in method.
func set_request_callback(callback : Callable) -> void:
	request = callback


# Sets the prompt message to the passed-in string.
func set_prompt_message(message : String) -> void:
	prompt_message = message


# Begin an interaction with the entity, creating a request if a callback function
# is defined, or skipping straight to process if not.
func interact() -> InteractionRequest:
	if request.is_valid():
		return request.call()
	
	return


# Processes a previously validated interaction by calling a callable passed in
# from the parent.
func process_interaction() -> void:
	process.call()
