class_name PickUpItemResponse
extends InteractionResponse

## Declares the data shape required to complete an item pick up request upon
## interacting with something.


# Reference to the item configuration.
var data : ItemDefinition

# Amount of the item that is being picked up.
var amount : int
