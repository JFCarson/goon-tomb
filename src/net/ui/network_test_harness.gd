extends Control


func _on_server_pressed() -> void:
	NetHandler.start_server()


func _on_client_pressed() -> void:
	NetHandler.start_client()
