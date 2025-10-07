extends Node2D

@export var rays: Array[RayCast2D]

func _ready() -> void:
	for ray in rays:
		ray.set_collision_mask_value(3, true)
		
func _process(delta: float) -> void:
	for ray in rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider is TileMapLayer:
				crash_wall.emit(ray.name.to_lower())
				
signal crash_wall(name: String)
