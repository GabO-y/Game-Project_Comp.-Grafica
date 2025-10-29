extends Split

class_name MinSplit

@export var ghost: Ghost

var in_game = false

func _ready() -> void:
	body = ghost.body

func _process(delta: float) -> void:
	for ray in node_rays.rays:
		ray.global_position = body.global_position
		
