extends Enemy

class_name Skeleton

@export var ray: RayCast2D
@export var ray_marker: Marker2D

var arrow_speed: float

# new 

var dash_target_pos: Vector2

func _ready() -> void:
	current_state = EnemyState.DASHING
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
	if wait_frames_count > wait_frames_duration:
		setup_state(EnemyState.DASHING)
		return
	wait_frames_count += 1
	
func attacking_state(delta: float):
	if take_damage_frames_count > take_damage_coldown_frames:
		attack()
		setup_state(EnemyState.WAITING)
		return
	take_damage_frames_count += 1

	
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
			wait_frames_count = 0
		EnemyState.ATTACKING:
			take_damage_frames_count = 0
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

func animation_logic():
	
	var play = str(
		("walk" if current_state == EnemyState.DASHING else "idle"),
		("_back" if dir.y < 0 else "")
		)
		
	anim.flip_h = dir.x > 0
	anim.play(play)
	
func attack():
	
	var b = load("res://Cenas/Enemy/Skeleton/SkeletonBullet/SkeletonBullet.tscn").instantiate() as SkeletonArrow
	Globals.room_manager.current_room.add_child(b)
	b.global_position = body.global_position
	
	b.speed = arrow_speed
	b.damage = damage
	b.dir = dir_to_player()
	b.rotation = b.dir.angle()
	b.start()
	
func setup_status():
	attributes = {
		"heart": SimpleAttribute.new(15, 4, 9),
		"damage": SimpleAttribute.new(2, 1, 9),
		"speed": SimpleAttribute.new(150.0, 100.0, 9),
		"arrow_speed": SimpleAttribute.new(5.0, 3.5, 9),
		"wait_frames": SimpleAttribute.new(40, 70, 9),
		"take_damage": SimpleAttribute.new(20, 60, 9)
	}
	update_all_status()

func update_status(name: String):
	var attr: SimpleAttribute = super.update_status(name)
	match name:
		"arrow_speed": arrow_speed = attr.get_value(level)
	return attr
	
