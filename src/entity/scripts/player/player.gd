class_name PlayerOrchestrator
extends CharacterBody3D

## Orchestrator script for the player.

# Top-level flag to run debug functions. This cascades to all descendents which
# have a debug variable declared.
@export var debug : bool = false


## Components
@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var collision : CollisionShape3D = $CollisionShape3D
@onready var hud : HUD = $ScreenOverlays/HUD


## Runtime State
var standing_height : float


## Controllers
const CONTROLLER := PlayerEnums.PlayerControllers
# Contains references to all controllers on the player entity.
#
# Note: The order of this dictionary determines the order the components are
# initialised in.
@onready var controller : Dictionary[CONTROLLER, Node] = {
	CONTROLLER.STATE: $EntityStateController,
	CONTROLLER.RESOURCE: $EntityResourceController,
	CONTROLLER.CAMERA: $GameCameraController,
	CONTROLLER.ACTION: $PlayerActionController,
	CONTROLLER.INTERACTION: $PlayerInteractionController,
	CONTROLLER.MOVEMENT: $PlayerMovementController,
	CONTROLLER.INVENTORY: $PlayerInventoryController,
	CONTROLLER.DAMAGE: $EntityDamageController
}


## Configuration
@export var config : PlayerConfig


## Process
func _ready() -> void:
	_validate()
	
	# Propagate debug flag to children if turned on.
	if debug:
		for child : Node in get_children():
			_propagate_debug(child)
	
	# Connect sibling components to the Interaction component.
	controller[CONTROLLER.INTERACTION].interact_ray = controller[CONTROLLER.CAMERA].get_interact_ray()
	controller[CONTROLLER.INTERACTION].prompt = hud.get_interact_prompt()
	
	# Initialise each controller.
	for i in controller:
		var target : Node = controller[i]
		
		target.config = config
		target.initialise(controller[CONTROLLER.STATE], controller[CONTROLLER.RESOURCE])
	
	# Listen for state change signals.
	controller[CONTROLLER.STATE].state_changed.connect(_on_state_changed)
	
	# Listen for damage or healing.
	controller[CONTROLLER.DAMAGE].damage_taken.connect(_on_damage_taken)
	controller[CONTROLLER.DAMAGE].health_restored.connect(_on_health_restored)
	
	# Listen for unique requests from interactions.
	controller[CONTROLLER.INTERACTION].interaction_request.connect(_on_interaction_request)
	
	# Listen to changes to the player's inventory.
	controller[CONTROLLER.INVENTORY].inventory.inventory_updated.connect(_on_inventory_updated)
	
	# Initialise the HUD with the entity's resource values.
	hud.initialise(controller[CONTROLLER.RESOURCE].get_max_health(), controller[CONTROLLER.RESOURCE].get_max_stamina())
	
	# Store default height as the standing height.
	standing_height = collision.shape.height
	
	# Capture the player's mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		var yaw_delta : float = controller[CONTROLLER.CAMERA].process_look(event.relative)
		rotate_y(yaw_delta)


func _process(delta : float) -> void:
	controller[CONTROLLER.CAMERA].process_camera_effects(delta, velocity)
	controller[CONTROLLER.INTERACTION].update_interaction()


func _physics_process(delta : float) -> void:
	var action_list : Array[EntityEnums.Action] = controller[CONTROLLER.ACTION].create_action_list()
	
	_process_movement(delta, action_list)
	_process_resources(delta, action_list)
	_process_damage()
	_process_interaction(action_list)


## Private Methods
# Processes all movement for the entity from one method.
func _process_movement(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	_process_gravity(delta)
	
	if _is_alive():
		_process_velocity(delta, action_list)
		_process_jump(action_list)
		_process_crouch(delta, action_list)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()


# Processes gravity for the entity.
func _process_gravity(delta : float) -> void:
	controller[CONTROLLER.MOVEMENT].is_on_floor = is_on_floor()
	
	if not is_on_floor():
		velocity += get_gravity() * delta


# Processes velocity for the entity.
func _process_velocity(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	var movement_action : Vector2 = controller[CONTROLLER.ACTION].get_move_action()
	
	velocity = controller[CONTROLLER.MOVEMENT].process_movement(delta, velocity, transform.basis, movement_action, action_list)


# Processes jump requests for the entity.
func _process_jump(action_list : Array[EntityEnums.Action]) -> void:
	if not action_list.has(EntityEnums.Action.JUMP):
		return
	
	if not controller[CONTROLLER.MOVEMENT].can_jump():
		return
	
	if not controller[CONTROLLER.RESOURCE].can_jump():
		return
	
	velocity = controller[CONTROLLER.MOVEMENT].process_jump(velocity)
	controller[CONTROLLER.RESOURCE].consume_jump()


# Processes changes to the entity when crouching.
func _process_crouch(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	collision.shape.height = controller[CONTROLLER.MOVEMENT].process_crouch(delta, collision.shape.height, standing_height, action_list)


# Processes the entity's resource systems.
func _process_resources(delta : float, action_list : Array[EntityEnums.Action]) -> void:
	var is_sprinting : bool = action_list.has(EntityEnums.Action.SPRINT)
	var resource_controller : EntityResourceController = controller[CONTROLLER.RESOURCE]
	
	resource_controller.update(delta, is_sprinting)
	
	hud.update_health(resource_controller.get_health())
	hud.update_stamina(resource_controller.get_stamina())


# Processes interaction requests for the entity.
func _process_interaction(action_list : Array[EntityEnums.Action]) -> void:
	if action_list.has(EntityEnums.Action.INTERACT):
		controller[CONTROLLER.INTERACTION].try_interact()


# Processes damage detection for the entity.
func _process_damage() -> void:
	controller[CONTROLLER.DAMAGE].update_fall_damage(is_on_floor(), velocity)


# Returns whether the entity is currently alive.
func _is_alive() -> bool:
	return controller[CONTROLLER.STATE].check(EntityStateEnums.States.LIFECYCLE) == EntityStateEnums.Lifecycle.ALIVE


## Listeners
# Listen for changes to states.
func _on_state_changed(target_state : EntityStateEnums.States, value : int) -> void:
	if target_state == EntityStateEnums.States.LIFECYCLE:
		hud.update_lifecycle(value)


# Listen for requests to pick up an item.
func _on_interaction_request(request : InteractionRequest) -> void:
	if request is PickUpItemRequest:
		if controller[CONTROLLER.INVENTORY].add_item(request.item, request.amount):
			controller[CONTROLLER.INTERACTION].finish_interaction(request.ref)


# Listen for changes to the player's inventory.
func _on_inventory_updated(inventory : Inventory, weight : float, max_weight : float) -> void:
	print("Inventory:")
	for i in inventory.items:
		print("%s x %s" % [i.amount, i.definition.name])
	print("Current Weight: %s" % weight)
	print("Max Weight: %s" % max_weight)

# Listen for damage being dealt.
func _on_damage_taken(amount : float) -> void:
	var max_health : float = controller[CONTROLLER.RESOURCE].get_max_health()
	var magnitude : float = amount / max_health
	
	hud.health_feedback(magnitude, HUD.DAMAGE_FEEDBACK_COLOUR)
	controller[CONTROLLER.CAMERA].cause_damage_feedback(magnitude)


# Listen for healing.
func _on_health_restored(amount : float) -> void:
	var max_health : float = controller[CONTROLLER.RESOURCE].get_max_health()
	var magnitude : float = amount / max_health
	
	hud.health_feedback(magnitude, HUD.HEALING_FEEDBACK_COLOUR)


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
	_validate_controller_dependencies()
	_validate_config()


# Validates that all required components have been added as children of the
# class.
func _validate_required_children() -> void:
	assert(mesh != null, "The Player component requires a MeshInstance3D component as a direct child.")
	assert(collision != null, "The Player component requires a CollisionShape3D component as a direct child.")
	assert(collision.shape != null, "The Player component requires a Shape resource on its CollisionShape3D component.")
	assert(collision.shape is CapsuleShape3D, "The Player component requires a CapsuleShape3D collision shape.")


# Validates that all assigned controllers are of the Controller or Controller3D
# class definition.
func _validate_controller_classes() -> void:
	for i in controller:
		assert(controller[i] != null, "%s controller must not be null." % CONTROLLER.keys()[i])
		assert(controller[i] is EntityController or controller[i] is EntityController3D, "%s must be either an EntityController or EntityController3D component." % CONTROLLER.keys()[i])


# Validates that all required controllers are present in the composition.
func _validate_controller_dependencies() -> void:
	assert(CONTROLLER.CAMERA in controller, "The Player component requires a camera controller.")
	assert(CONTROLLER.ACTION in controller, "The Player component requires an action controller.")
	assert(CONTROLLER.MOVEMENT in controller, "The Player component requires a movement controller.")
	assert(CONTROLLER.STATE in controller, "The Player component requires a state controller.")
	assert(CONTROLLER.RESOURCE in controller, "The Player component requires a resource controller.")
	assert(CONTROLLER.DAMAGE in controller, "The Player component requires a damage controller.")


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
