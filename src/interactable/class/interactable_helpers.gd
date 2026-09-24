class_name InteractableHelpers
extends RefCounted

## Helper functions for dealing with interactables.


# Create a new pick up item response.
static func create_pick_up_item_response(data : ItemDefinition, amount : int) -> PickUpItemResponse:
	var response := PickUpItemResponse.new()
	
	response.type = InteractableEnums.ResponseType.PICK_UP
	response.data = data
	response.amount = amount
	
	return response
