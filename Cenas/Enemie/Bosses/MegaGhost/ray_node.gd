extends Node2D

@export var rays: Array[RayCast2D]

func _process(delta: float) -> void:
	for ray in rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider is TileMapLayer:
				crash_wall.emit(collider.name.to_lower())
			
signal crash_wall(wall_name: String)
