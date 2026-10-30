@abstract
class_name EntityComponent3D
extends Node3D

## Base class definition for entity components that are managed by an
## EntityController3D component.


# Config
## Keeps reference to the controller of the managed entity.
var controller : EntityController3D


# Process
## Initialises the movement component.
func initialise(controller_component : EntityController3D) -> void:
	controller = controller_component
	
