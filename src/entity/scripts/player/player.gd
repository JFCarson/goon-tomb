class_name PlayerOrchestrator
extends CharacterBody3D

## Orchestrator script for the player.

# Top-level flag to run debug functions. This cascades to all descendents which
# have a debug variable declared.
@export var debug : bool = false

# Components
@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var collision : CollisionShape3D = $CollisionShape3D

var hud : HUD

# Runtime
var standing_height : float

# Controllers
const CONTROLLER := PlayerEnums.PlayerControllers
@onready var controller : Dictionary[CONTROLLER, Node] = {
	CONTROLLER.CAMERA: $GameCameraController,
	CONTROLLER.ACTION: $PlayerActionController,
	CONTROLLER.MOVEMENT: $PlayerMovementController,
	CONTROLLER.STATE: $EntityStateController,
	# CONTROLLER.RESOURCES: $EntityResourceController
}

@onready var interact : Interaction = $Interaction

# Configuration
@export var config : PlayerConfig


func initialise(player_hud : HUD) -> void:
	hud = player_hud
	
	# Propogate debug flag to children if turned on.
	if debug:
		for child : Node in get_children():
			_propagate_debug(child)
	
	# Initialise each controller.
	for i in controller:
		var target : Node = controller[i]
		
		target.config = config
		target.initialise(controller[CONTROLLER.STATE])
	
	# Connect sibling components to the Interaction component.
	interact.interact_ray = controller[CONTROLLER.CAMERA].get_interact_ray()
	interact.prompt = hud.get_interact_prompt()


## Process
func _ready() -> void:
	standing_height = collision.shape.height
	
	if debug:
		_validate()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		var yaw_delta : float = controller[CONTROLLER.CAMERA].process_look(event.relative)
		rotate_y(yaw_delta)


func _process(delta : float) -> void:
	controller[CONTROLLER.CAMERA].process_camera_effects(delta, velocity)
	interact.update_interaction()


func _physics_process(delta : float) -> void:
	var action_list : Array[EntityEnums.Action] = controller[CONTROLLER.ACTION].create_action_list()
	
	_process_movement(delta, action_list)
	_process_interaction(action_list)


## Private Methods
# Processes all movement for the entity from one method.
func _process_movement(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	_process_gravity(delta)
	_process_velocity(delta, action_list)
	_process_crouch(delta, action_list)
	
	move_and_slide()


# Processes gravity for the entity.
func _process_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	controller[CONTROLLER.MOVEMENT].is_on_floor = is_on_floor()


# Processes velocity for the entity.
func _process_velocity(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	var movement_action : Vector2 = controller[CONTROLLER.ACTION].get_move_action()
	
	velocity = controller[CONTROLLER.MOVEMENT].process_movement(delta, velocity, transform.basis, movement_action, action_list)


# Processes changes to the entity when crouching.
func _process_crouch(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	collision.shape.height = controller[CONTROLLER.MOVEMENT].process_crouch(delta, collision.shape.height, standing_height, action_list)


# Processes interaction requests for the entity.
func _process_interaction(action_list : Array[EntityEnums.Action]) -> void:
	if action_list.has(EntityEnums.Action.INTERACT):
		interact.try_interact()


## Debug
func _propagate_debug(node : Node) -> void:
	var has_debug : bool = false
	for property : Dictionary in node.get_property_list():
		if property["name"] == &"debug":
			has_debug = true
	
	if has_debug:
		node.debug = debug
	
	for child : Node in node.get_children():
		_propagate_debug(child)


## Validation
# Run a full validation pass of the component.
func _validate() -> void:
	_validate_required_children()
	_validate_controller_classes()
	_validate_config()


# Validates that all required components have been added as children of the
# class.
func _validate_required_children() -> void:
	assert(mesh != null, "The Player component requires a MeshInstance3D component as a direct child.")
	assert(collision != null, "The Player component requires a CollisionShape3D component as a direct child.")
	assert(interact != null, "The Player component requires an Interaction component as a direct child.")


# Validates that all assigned controllers are of the Controller or Controller3D
# class definition.
func _validate_controller_classes() -> void:
	for i in controller:
		assert(controller[i] is EntityController or controller[i] is EntityController3D, "%s must be either an EntityController or EntityController3D component." % CONTROLLER.keys()[i])


# Validates that configuration has been assigned to the composition.
func _validate_config() -> void:
	assert(config != null, "Config must be added via the Player component's inspection window.")
	_validate_resource(config, "config")


# Validates all properties recursively in a resource.
func _validate_resource(resource : Resource, path : String = "") -> void:
	for property : Dictionary in resource.get_property_list():
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		
		var property_name : StringName = property["name"]
		var value : Variant = resource.get(property_name)
		var current_path : String = ("%s.%s" % [path, property_name] if not path.is_empty() else str(property_name))
		
		if value == null:
			assert(false, "Config property '%s' must not be null." % current_path)
		
		if value is Resource:
			_validate_resource(value, current_path)
