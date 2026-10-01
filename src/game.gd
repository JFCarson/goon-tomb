class_name Game
extends Node3D

## Root node for all scene trees.


# DEBUG CODE: Closes the active game window on ESC.
func _input(event: InputEvent) -> void:
	if event is InputEventKey: 
		if event.pressed: 
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()
