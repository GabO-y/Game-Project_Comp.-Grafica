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
				var wall_name = ray.name.replace("Ray", "").to_lower()
				crash_with.emit(wall_name)
				
signal crash_with(wall_name: String)
