extends Interactable

@export var press_distance: float = 0.1
var pressed : bool = false
var original_position: Vector3

func _ready() -> void:
	original_position = position

func interact() -> void:
	if pressed:
		return

	pressed = true

	position.y -= press_distance

	print("Button pressed!")
