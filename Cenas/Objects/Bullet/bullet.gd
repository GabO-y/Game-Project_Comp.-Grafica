extends Sprite2D

class_name Bullet

@export var collision_area: Area2D

@export var speed: float = 4.0
@export var life_time_frames: int = 0
var frames: int = 0

var dir: Vector2 = Vector2.RIGHT
var last_dir: Vector2 = Vector2.RIGHT

var is_to_move: bool = true

func _ready() -> void:
	set_physics_process(false)

func start():
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if is_to_move: move(delta)
	
func move(delta: float):
	if life_time_frames > 0 and frames > life_time_frames:
		queue_free()
		return
	frames += 1
	if dir == Vector2.ZERO:
		dir = last_dir
	else:
		last_dir = dir
	global_position += dir.normalized() * speed
	
