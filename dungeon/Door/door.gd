class_name Door
extends AnimatableBody3D


## Configuration
@export var open_angle : float = 90.0
@export var open_time : float = 2.0


## Components
@onready var door_open_audio : AudioStreamPlayer3D = $DoorOpen
@onready var door_close_audio : AudioStreamPlayer3D = $DoorClose
@onready var interactable : Interactable = $Interactable


## Runtime State
var is_open : bool = false
var is_moving : bool = false

var closed_rotation : float
var open_rotation : float

var door_tween : Tween


## Process
func _ready() -> void:
	interactable.set_process_callback(toggle_door)
	
	closed_rotation = rotation_degrees.y
	open_rotation = closed_rotation - open_angle


## Public Interface
func toggle_door() -> void:
	if is_moving:
		return
	
	is_open = not is_open
	is_moving = true
	
	if is_open:
		door_open_audio.play()
		_move_to_rotation(open_rotation)
	else:
		door_close_audio.play()
		_move_to_rotation(closed_rotation)


## Private Methods
func _move_to_rotation(target_rotation : float) -> void:
	if door_tween:
		door_tween.kill()
	
	var current_rotation : float = rotation_degrees.y
	
	# Find the equivalent target rotation closest to the current rotation.
	target_rotation += round((current_rotation - target_rotation) / 360.0) * 360.0
	
	door_tween = create_tween()
	door_tween.set_trans(Tween.TRANS_QUAD)
	door_tween.set_ease(Tween.EASE_IN_OUT)
	
	door_tween.tween_property(self, "rotation_degrees:y", target_rotation, open_time)
	
	door_tween.finished.connect(_on_door_finished)


func _on_door_finished() -> void:
	is_moving = false
	door_tween = null
