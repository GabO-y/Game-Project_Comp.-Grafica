extends Node2D

@export var player: Player
@export var ray_stuck_wall_handler: RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func test_wall_stuck():
	while ray_stuck_wall_handler.rotation <= deg_to_rad(360.0):
		if ray_stuck_wall_handler.is_colliding():
			var dir: Vector2 = ray_stuck_wall_handler.target_position.direction_to(player.body.global_position)
			var i: int = 0
			while ray_stuck_wall_handler.is_colliding():
				player.body.velocity += dir 
				player.body.move_and_slide()
				i += 1
				if i == 100:
					break
					
		ray_stuck_wall_handler.rotation += deg_to_rad(1.0)
