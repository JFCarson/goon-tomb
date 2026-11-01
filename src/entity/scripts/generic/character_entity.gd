@abstract
class_name CharacterEntity
extends CharacterBody3D

## Abstract orchistrator base class for all character entities.


# Components
## Keeps reference to the entity's mesh.
@onready var mesh : MeshInstance3D = $MeshInstance3D

## Keeps reference to the entity's collision shape.
@onready var collision : CollisionShape3D = $CollisionShape3D


# Configuration
## Provides the baseline config to initialise the entity's controller children.
@export var config : EntityConfig


# Controllers
## Keeps reference to the generic entity controllers that each CharacterEntity
## must possess as children.
@export_group("Controllers")

## Keeps reference to the entity's state controller component.
@export var state : EntityStateController

## Keeps reference to the entity's damage controller component.
@export var damage : EntityDamageController

## Keeps reference to the entity's stats controller component.
@export var stats : EntityStatsController

## Keeps reference to the entity's networking controller component.
@export var networking : EntityNetworkingController


# Process
## Initialise the entire CharacterEntity composition when ready.
func _ready() -> void:
	# Initialise each controller.
	for controller : EntityController in [state, damage, stats, networking]:
		controller.initialise(self)


# Public Interface
## Returns whether the player is alive.
func is_alive() -> bool:
	if not state.is_tracking(EntityStateEnums.States.LIFECYCLE):
		return false
	
	return state.check(EntityStateEnums.States.LIFECYCLE) == EntityStateEnums.Lifecycle.ALIVE
