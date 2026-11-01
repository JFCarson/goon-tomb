class_name InteractionRequest
extends RefCounted

## Declares the base data shape required to complete an interaction.

# References the Interactable of the entity which was interacted with.
var ref : Interactable

# Defines the response type.
var type : InteractableEnums.ResponseType
