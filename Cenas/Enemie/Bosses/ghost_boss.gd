extends Enemy
class_name GhostBoss

var in_special_attack:bool = false

func _ready() -> void:
	set_active(true)

func _process(delta: float) -> void:
	_animation_logic()
	
func _physics_process(delta: float) -> void:
	
	if not is_active or is_stop: return
	
	test_move()

func _animation_logic():
	
	var play: String = "walk"
	
	if dir == Vector2.ZERO:
		dir = last_dir
	else:
		last_dir = dir
	
	if dir.y < 0:
		play += "_back"
	
	anim.flip_h = dir.x < 0
	anim.play(play)

func set_active(mode: bool):
	
	if mode: setup()
	
	set_process(mode)
	set_physics_process(mode)
	is_active = mode
	visible = mode
	
func setup():
	body.collision_layer = Globals.layers["boss"]
	body.collision_mask = Globals.layers["player"]
	
func test_move():
	dir = body.global_position.direction_to(get_global_mouse_position())
	body.velocity = dir * 100
	body.move_and_slide()
