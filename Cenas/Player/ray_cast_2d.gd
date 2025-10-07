extends RayCast2D

func _process(delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		print(collider.name)
