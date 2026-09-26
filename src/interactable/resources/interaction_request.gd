class_name InteractionRequest
extends Resource

## Declares the base data shape required to complete an interaction.

# References the entity which was interacted with. Should be set to 'self' when
# the resource is created.
var ref : Interactable

# Defines the response type.
var type : InteractableEnums.ResponseType
