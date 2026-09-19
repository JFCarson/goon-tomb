class_name Interactable
extends StaticBody3D

#This will act as a basic pseudo interface for all interactable objects i.e. levers, doors, simple talkable npcs

@export var prompt_message: String = "Interact"
@export var prompt_action: String = "interact"

func get_prompt() -> String:
	var key_name : String = ""
	#finds input key for interact
	for event in InputMap.action_get_events(prompt_action):
		if event is InputEventKey:
			if event.physical_keycode != 0:
				key_name = OS.get_keycode_string(event.physical_keycode)
			elif event.keycode != 0:
				key_name = OS.get_keycode_string(event.keycode)
	#parses a string to the interact prompt
	return prompt_message + "\n[" + key_name + "]"

func interact() -> void:
	pass
