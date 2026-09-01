class_name Lever
extends Interactable

@export var is_on: bool = false
@export var on_angle: float = -90.0
@export var off_angle: float = 0
@export var animation_time: float = 0.2

@onready var lever_arm: Node3D = $LeverModel/Lever
@onready var lever_down_audio: AudioStreamPlayer3D = $LeverDownSound
@onready var lever_up_audio: AudioStreamPlayer3D = $LeverUpSound

signal toggled(is_on: bool)

func interact() -> void:
	is_on = !is_on
	if is_on:
		activate()
		lever_down_audio.play()
	else:
		deactivate()
		lever_up_audio.play()
	toggled.emit(is_on)


func activate() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(
		lever_arm,
		"rotation_degrees:z",
		on_angle,
		animation_time
	)

func deactivate() -> void:
	var tween : Tween =  create_tween()
	tween.tween_property(
		lever_arm,
		"rotation_degrees:z",
		off_angle,
		animation_time
	)
