class_name EntityStateEnums
extends RefCounted

## Enums & maps for the an entity's state controller & components.


# Defines a list of states that an entity can track.
enum States {
	MOTION,
	LIFECYCLE
}


# Maps each enumerated value from States to the state value list.
static var state_components : Dictionary[States, Variant] = {
	States.MOTION: Motion,
	States.LIFECYCLE: Lifecycle
}


## State Value Lists
enum Motion {
	IDLE,
	WALKING,
	SPRINTING,
	CROUCHING,
	AIRBORNE
}


enum Lifecycle {
	ALIVE,
	DOWNED,
	DEAD
}
