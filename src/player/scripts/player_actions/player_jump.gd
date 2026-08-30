class_name PlayerJump
extends Node

## Handles jump calculations for the player.


# Configuration
@export var jump_settings : PlayerJumpSettings


## Public Interface
# Determines whether the player can currently jump.
func can_jump(is_on_floor : bool) -> bool:
	return is_on_floor


# Calculates the vertical velocity required to reach the configured jump height.
func calculate_jump_velocity() -> float:
	return sqrt(2.0 * jump_settings.jump_height)
