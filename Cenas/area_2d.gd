extends Area2D
	
func _on_light_area(body: Area2D) -> void:
	if(body.name == "Lantern"):
		print("Algo")
	else:
		print(body.name)
	
	
	
	
	
