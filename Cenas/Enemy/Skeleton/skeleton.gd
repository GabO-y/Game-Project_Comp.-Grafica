extends Enemy

class_name Skeleton

@export var ray: RayCast2D
@export var ray_marker: Marker2D

enum State {PREPARE_ATTACK, DASHING, AWAITING}

var attack_coldown: float = 3.0

var prepere_attack_update: float = 1.5

var duration: float = 0.0
var timer: float = 0.0

var dash_speed: float = 80.0
var target_pos_dash: Vector2

# como o esqueleto so para quando nao estiver colidiondo em ngm,
# conforme ele colide, o tempo do dash tbm diminui
var count_collision: int = 0

#var current_state: State 

# prepere -> await -> dash

# new 

var dash_target_pos: Vector2

func _ready() -> void:
	#current_state = State.PREPARE_ATTACK
	setup_prepere_attack()
	speed = 80
	super._ready()

func _process(delta: float) -> void:
	animation_logic()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#if !is_active or is_stop:
		#return
	#
	#match current_state:
		#State.DASHING:
			#dash_move(delta)
		#State.PREPARE_ATTACK:
			#prepere_attack_logic(delta)
		#State.AWAITING:
			#await_move(delta)
			#
	#super._process(delta)
	
func waiting_state(delta: float):
	if t > d:
		setup_state(EnemyState.DASHING)
		return
	t += delta
	
func attacking_state(delta: float):
	if t > d:
		attack()
		setup_state(EnemyState.WAITING)
		return
	t += delta
	
func dashing_state(delta: float):
	if t > d:
		setup_state(EnemyState.ATTACKING)
		return
	body.velocity = dash_target_pos * speed
	body.move_and_slide()
	t += delta
	
func setup_state(state: EnemyState, d: float = -1.0, t: float = -1.0):
	match state:
		EnemyState.WAITING:
			self.t = 0.0
			self.d = 0.5
		EnemyState.ATTACKING:
			self.t = 0.0
			self.d = 2.0
		EnemyState.DASHING:
			dash_target_pos = Vector2(
				randf_range(-1.0, 1.0),
				randf_range(-1.0 ,1.0)
			).normalized()
			self.t = 0.0
			self.d = 0.4
	if d > -1: self.d = d
	if t > -1: self.t = t
	current_state = state

func dash_move(delta: float):
	
	var collison = body.move_and_collide(dir)
	
	if collison:
		count_collision += 1
		setup_new_direction_point()
		setup_dash()
		duration -= count_collision * 0.1

	if timer >= duration:
		#current_state = State.PREPARE_ATTACK
		setup_prepere_attack()
		dir = dir_to_player()
		return
		
	timer += delta
	
	body.velocity = dir * speed
	body.move_and_slide()
	
func animation_logic():
	
	var play = str(
		("walk" if current_state == State.DASHING else "idle"),
		("_back" if dir.y < 0 else "")
		)
		
	anim.flip_h = dir.x > 0
	anim.play(play)
	
func prepere_attack_logic(delta: float):
		
	if timer >= duration:
		attack()
		
		setup_await()
		return
		
	timer += delta
	
func attack():
	
	var b = load("res://Cenas/Enemy/Skeleton/SkeletonBullet/SkeletonBullet.tscn").instantiate() as Bullet
	Globals.room_manager.current_room.add_child(b)
	b.global_position = body.global_position
	
	b.speed = 4
	b.dir = dir_to_player()
	b.rotation = b.dir.angle()
	b.start()
	
func await_move(delta):
	if timer >= duration:
		count_collision = 0
		setup_new_direction_point()
		setup_dash()
		return
	timer += delta
	
func setup_new_direction_point():
	var possibles_points = rotate_and_get_possibles_points()
	var p: Vector2
	if not possibles_points.is_empty():
		p = possibles_points.pick_random()
	else:
		p = dir_to_player()
	target_pos_dash = p
	dir = body.global_position.direction_to(target_pos_dash)

func rotate_and_get_possibles_points() -> Array[Vector2]:
	var rotates: int = 100
	var avaliable_pos: Array[Vector2] = []
	for i in range(rotates):
		if not ray.is_colliding():
			avaliable_pos.append(ray_marker.global_position)
		ray.rotation += (2 * PI) / rotates
	return avaliable_pos
		
func setup_dash():
	duration = 0.5
	timer = 0.0
	#current_state = State.DASHING

func setup_prepere_attack():
	duration = 3.0 - (prepere_attack_update * (float(level)/9.0))
	timer = 0.0
	#current_state = State.PREPARE_ATTACK
	
func setup_await():
	duration = 2.0
	timer = 0.0
	#current_state = State.AWAITING
		
func rotate_ray(t: float):
	ray.rotate(t)
	
	if ray.is_colliding():
		return null
		
	return ray.target_position
	
func setup():
	super.setup()
	
func set_level(lv: int, what):
	super.set_level(lv, what)
	level = lv
	
func default_setup():
	
	atributes.append_array([
		damage_att, speed_att, health_att
	])
	
	damage_att.setup(1, 1,"value")
	speed_att.setup(100, 150, "value")
	health_att.setup(3.0, 5.0, "value")
	
	set_level(9, "max")

	
	
