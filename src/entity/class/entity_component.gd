@abstract
class_name EntityComponent
extends Node

## Base class definition for entity components that are managed by an
## EntityController component.


# Config
## Keeps reference to the controller of the managed entity.
var controller : EntityController


# Process
## Initialises the movement component.
func initialise(controller_component : EntityController) -> void:
	controller = controller_component
	
