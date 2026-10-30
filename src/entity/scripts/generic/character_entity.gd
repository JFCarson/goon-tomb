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

## Keeps reference to the entity's resource controller component.
@export var resource : EntityResourceController

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
	for controller : EntityController in [state, resource, damage, stats, networking]:
		controller.initialise(self)
	
	# Connect signals to listener functions.
	_connect_signals()


# Private Methods
## Connect signals to listener functions.
func _connect_signals() -> void:
	damage.damage_taken.connect(_on_damage_taken)


# Signal Methods
## Listen for requests to process incoming damage.
@abstract
func _on_damage_taken(amount: float) -> void
