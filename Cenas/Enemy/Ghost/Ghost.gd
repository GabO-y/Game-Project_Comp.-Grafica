extends Enemy

class_name Ghost

var animation_type: int
var mouse_pos: Vector2

# Variaveis referentes ao ataque
var time_attack = 0.5;
var timer_attack = 0
var last_dir_player: Vector2
var is_continue_toward := false

var is_dashing := false
var dash_dir: Vector2
var dash_duration := 0.4
var dash_timer = 0
var dash_speed := 200
var is_prepare_attack = false

var wait_timer = 0
var wait_duration = 1.2

var special_attack = ""

var voice_random_time: float = 1.0
var voice_timer: float = 0.0

enum State {
	CHASE,
	PREPARE_ATTACKING,
	DASHING,
	SPECIAL
}

var type_special: int

#var current_state: State

@export var area_hit: Area2D
@export var screen_notifier: VisibleOnScreenNotifier2D

# new 

@export var animated_slash_attck: AnimatedSprite2D
@export var slash_attack_area: Area2D

var current_custom_state: CustomState = CustomState.SPECIAL
var special_stage: int = 1

func _ready() -> void:
	animation_type = randi_range(1, 4)
	super._ready()
	default_setup()
	
func _process(delta: float) -> void:
	animation_logic()
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	#if not is_active or is_stop: return
	#
	#match current_state:
		#State.CHASE:
			#chase_player(dist_to_player())
		#State.PREPARE_ATTACKING:
			#prepare_attack(delta)
		#State.DASHING:
			#dash(delta)
		#State.SPECIAL:
			#print("especial")
			#special_move()
	
func waiting_state(delta: float):
	if t > d:
		setup_state(EnemyState.CHESING)
		return
	t += delta
	
func chesing_state(delta: float):
	if dist_to_player() < 15.0:
		setup_state(EnemyState.ATTACKING)
		return
	body.velocity = dir_to_player() * speed
	body.move_and_slide()
		
func attacking_state(delta: float):
	if t > d: 
		play_attack_animation()		
		for body in slash_attack_area.get_overlapping_bodies():
			if body.get_parent() is Player:
				Globals.player.take_damage(damage)
		setup_state(EnemyState.WAITING)
		return
	t += delta

func custom_state(delta: float):
	match current_custom_state:
		CustomState.SPECIAL:
			match special_stage:
				1:
					t += delta
					if t > d:
						special_stage += 1
				2:
					if chase_player(70.0, 1.2):
						t = 0.0
						d = 3.0
						last_dir_player = dir_to_player()
						special_stage += 1
				3: 
					t += delta
					if t > d:
						queue_free()
					body.velocity = last_dir_player * speed * 1.2
					body.move_and_slide()
					
					

func setup_state(state: EnemyState, d: float = -1.0, t: float = -1.0):
	match state:
		EnemyState.WAITING:
			self.t = 0.0
			self.d = 0.5
		EnemyState.ATTACKING:
			self.t = 0.0
			self.d = 0.3
		EnemyState.CUSTOM:
			special_stage = 1
			t = 0.0
			# d é modificado no boss
	if t > -1: self.t = t
	if d > -1: self.d = d
		
	current_state = state

func play_attack_animation():
		
	if animated_slash_attck.visible: return

	animated_slash_attck.visible = true
	
	var dir: Vector2 = dir_to_player()
	
	animated_slash_attck.rotation = 0.0
	animated_slash_attck.rotation = dir.angle()

	animated_slash_attck.global_position += dir * 10
		
	animated_slash_attck.play("attack")
	setup_state(EnemyState.WAITING)

	await animated_slash_attck.animation_finished
	
	animated_slash_attck.visible = false
	animated_slash_attck.global_position = body.global_position

func special_move():
				
	body.collision_layer = Globals.layers["boss"] 
	body.collision_mask = 0
		
	match type_special:
		1: 
			move_special_1()
		2:
			body.velocity = dir * speed
			body.move_and_slide()
		
func move_special_1():
	
	if is_continue_toward:
		body.velocity = dir * speed
		body.move_and_slide()
		return
			
	if dist_to_player() < 70:
		is_continue_toward = true
		return
			
	chase_player(41)
	last_dir = dir
	
func prepare_attack(delta):
	
	wait_timer += delta

	if wait_timer >= wait_duration:
		#current_state = State.DASHING
		is_dashing = true
		wait_timer = 0
		dash_dir = dir_to_player()
		last_dir = dash_dir
				
func dash(delta):
		
	body.velocity = dash_dir * dash_speed
	body.move_and_slide()
		
	dash_timer += delta
		
	if dash_timer >= dash_duration:
		dash_timer = 0
		#current_state = State.CHASE
		is_dashing = false		
		body.collision_mask = Globals.layers["player"]
	
func animation_logic():
	
	if is_dead: return
	
	var play = "type_" + str(animation_type)
	if dir.y < 0:
		play = "back" + str("" if(
			animation_type % 2 != 0
		) else "_bald") 
	
	anim.flip_h = dir.x > 0
	anim.play(play)
	
func set_active(mode: bool):
	super.set_active(mode)
	
	var layer = Globals.layers["ghost"] if mode else 0
	var mask = Globals.layers["player"] if mode else 0
	
	body.collision_layer = layer
	body.collision_mask = mask
	
	area_hit.monitorable = mode
	area_hit.monitoring = mode
	
#func chase_player(dist):
	#
	#if (dist < 25):
		##current_state = State.PREPARE_ATTACKING
		#return
	#
	#if is_attacking: return
	#
	#dir = dir_to_player()
#
	#body.velocity = dir * speed
	#body.move_and_slide()
	
func enable():
	show()
	is_active = true
	refrash()

func _player_enter_hit(body: Node2D) -> void:
	
	return
	
	var player = body.get_parent() as Player
	if player == null: return
	player.take_knockback(dir, 10)
	player.take_damage(damage)

func refrash():
	body.collision_layer = Globals.layers["enemy"] | Globals.layers["ghost"]
	body.collision_mask = Globals.layers["player"]
	
func ghosts_run_move():
	
	var ene_pos = body.global_position
	var pla_pos = Globals.player_pos()
	
	var dist = ene_pos.distance_to(pla_pos)
	dir = ene_pos.direction_to(pla_pos)
	
	if dist <= 40 or is_continue_toward:
		dir = last_dir_player
		is_continue_toward = true
	else:
		last_dir_player = dir
	
	body.velocity = dir * speed
	body.move_and_slide()

func die():
	super.die()
	area_hit.collision_layer = 0
	area_hit.collision_mask = 0

func default_setup():
	
	atributes.append_array([
		health_att, speed_att, damage_att
	])
				
	speed_att.setup(80, 150, "value")
	damage_att.setup(1, 1, "value")
	health_att.setup(5, 15, "value")
	
	set_level(9, "max")

enum CustomState {SPECIAL}

	
