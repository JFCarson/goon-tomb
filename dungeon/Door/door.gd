class_name Door
extends Interactable

@export var open_angle: float = 90.0
@export var open_time: float = 2.0

@onready var door_open_audio: AudioStreamPlayer3D = $DoorOpen
@onready var door_close_audio: AudioStreamPlayer3D = $DoorClose
var is_open := false
var is_moving := false


func process_interaction() -> void:
	if not is_moving:
		is_open = not is_open
		is_moving = true
		
		if is_open:
			door_open_audio.play()
		else:
			door_close_audio.play()
		
		var target_rotation := deg_to_rad(open_angle) if is_open else 0.0

		var tween := create_tween()
		tween.tween_property(
			self,
			"rotation:y",
			target_rotation,
			open_time
		)

		tween.finished.connect(_on_door_finished)


func _on_door_finished() -> void:
	is_moving = false
