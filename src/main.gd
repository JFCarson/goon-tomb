class_name Main
extends Node

## Root node for all scene trees.


# Config
const main_menu_scene : PackedScene = preload("uid://do7gj7cl1efvm")
const dungeon_scene : PackedScene = preload("uid://bp2356hmcdw7")


# References
@onready var scene_container : Node = $SceneContainer


# Lifecycle
func _ready() -> void:
	load_scene(main_menu_scene)


# Public Interface
func load_scene(scene : PackedScene) -> void:
	if scene_container == null:
		push_error("SceneContainer was not found. Check the node path in Main.")
		return
		
	if scene == null:
		push_warning("Cannot load scene: supplied PackedScene is null.")
		return
		
	for child : Node in scene_container.get_children():
		scene_container.remove_child(child)
		child.queue_free()
		
	var instance : Node = scene.instantiate()
	scene_container.add_child(instance)


# DEBUG CODE: Closes the active game window on ESC.
func _input(event: InputEvent) -> void:
	if event is InputEventKey: 
		if event.pressed: 
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()
