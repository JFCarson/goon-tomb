class_name PlayerEnums
extends RefCounted

## Shared enumerations used by the player component and its children.


# Describes the player's current physical movement state.
# The player should occupy exactly one motion state at any given time.
enum MotionState {
	IDLE,
	WALKING,
	SPRINTING,
	AIRBORNE
}
