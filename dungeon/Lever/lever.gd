class_name Lever
extends StaticBody3D


## Configuration
@export var is_on : bool = false
@export var on_angle : float = -90.0
@export var off_angle : float = 0.0
@export var animation_time : float = 0.2


## Components
@onready var lever_arm : Node3D = $LeverModel/Lever
@onready var lever_down_audio : AudioStreamPlayer3D = $LeverDownSound
@onready var lever_up_audio : AudioStreamPlayer3D = $LeverUpSound
@onready var interactable : Interactable = $Interactable


## Signals
signal toggled(is_on : bool)


## Runtime State
var lever_tween : Tween


## Process
func _ready() -> void:
	interactable.set_process_callback(flip_lever)


## Public Interface
func flip_lever() -> void:
	is_on = not is_on
	
	if is_on:
		activate()
		lever_down_audio.play()
	else:
		deactivate()
		lever_up_audio.play()
	
	toggled.emit(is_on)


## Private Methods
func activate() -> void:
	_move_to_angle(on_angle)


func deactivate() -> void:
	_move_to_angle(off_angle)


func _move_to_angle(target_angle : float) -> void:
	if lever_tween:
		lever_tween.kill()
	
	var current_angle : float = lever_arm.rotation_degrees.z
	
	# Use the equivalent target angle closest to the current angle.
	target_angle += round((current_angle - target_angle) / 360.0) * 360.0
	
	lever_tween = create_tween()
	lever_tween.set_trans(Tween.TRANS_QUAD)
	lever_tween.set_ease(Tween.EASE_IN_OUT)
	
	lever_tween.tween_property(lever_arm, "rotation_degrees:z", target_angle, animation_time)
