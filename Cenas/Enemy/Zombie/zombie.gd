extends Enemy

class_name Zombie

@export var agent: NavigationAgent2D
@export var time: Timer

enum State { CHASING, DASHING, ATTACKING }
# var current_state: State = State.CHASING

var dash_timer = 0.0
var dash_duration = 0.5
var dash_direction: Vector2
var dash_speed = 100

var animation_type: int

var attack_cooldown = 0.0
var attack_rate = 1.5

var is_player_in_attack_range = false

# new 

@export var animated_slash_attack: AnimatedSprite2D
@export var slash_hit_area: Area2D

var last_dir_player: Vector2 = Vector2.RIGHT

func _ready() -> void:
	z_index = 1
	animation_type = get_aniamtion_tipy()
	super._ready()

func _process(delta: float) -> void:	
	animation_logic()
	super._process(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	#if !is_active or is_stop:
		#return
#
	#match current_state:
		#State.CHASING:
			#handle_chasing_state(dist_to_player())
		#State.DASHING:
			#handle_dashing_state(delta)
		#State.ATTACKING:
			#handle_attacking_state(delta)

func waiting_state(delta: float):
	if t > d:
		if dist_to_player() < 20.0:
			setup_state(EnemyState.ATTACKING, 0.5)
			return
		setup_state(EnemyState.CHESING)
		return
	t += delta
	
func chesing_state(delta: float):
	if dist_to_player() < 50.0:
		setup_state(EnemyState.DASHING)
		return
	agent.target_position = Globals.player_pos()
	var next_p: Vector2 = agent.get_next_path_position()
	body.velocity = body.global_position.direction_to(next_p) * speed
	body.move_and_slide()
	
func dashing_state(delta: float):
	if t > d:
		setup_state(EnemyState.ATTACKING)
		return
	body.velocity = last_dir_player * speed * 1.3
	body.move_and_slide()
	t += delta

func attacking_state(delta: float):
	if t > d:
		setup_state(EnemyState.WAITING)
		play_attack_animation()
		for body in slash_hit_area.get_overlapping_bodies():
			if body.get_parent() is Player:
				Globals.player.take_damage(1)
		return
	t += delta
	
func stuned_state(delta: float):
	pass
	
func play_attack_animation():
		
	if animated_slash_attack.visible: return

	animated_slash_attack.visible = true
	
	var dir: Vector2 = dir_to_player()
	
	animated_slash_attack.rotation = 0.0
	animated_slash_attack.rotation = dir.angle()

	animated_slash_attack.global_position += dir * 10
		
	animated_slash_attack.play("attack")
	setup_state(EnemyState.WAITING)

	await animated_slash_attack.animation_finished
	
	animated_slash_attack.visible = false
	animated_slash_attack.global_position = body.global_position

func setup_state(state: EnemyState, d: float = -1.0, t: float = -1.0):
	match state:
		EnemyState.WAITING:
			self.t = 0.0
			self.d = 0.5
		EnemyState.DASHING:
			last_dir_player = dir_to_player()
			self.t = 0.0
			self.d = 0.4
		EnemyState.ATTACKING:
			self.t = 0.0
			self.d = 0.0
	if t > -1: self.t = t
	if d > -1: self.d = d
		
	current_state = state

func handle_chasing_state(distance_to_player: float):
	
	var next_point = agent.get_next_path_position() 
	dir = body.global_position.direction_to(next_point).normalized()
	dir = dir.normalized()

	body.velocity = dir * speed
	
	body.move_and_slide()
	
	if distance_to_player < 40:
		is_stop = true
		await Globals.time(0.3)
		is_stop = false
		
		# current_state = State.DASHING
		dash_direction = dir_to_player()
		dash_timer = 0.0

func handle_dashing_state(delta: float):
	dash_timer += delta
	
	# Executar dash
	body.velocity = dash_direction * dash_speed
	body.move_and_slide()
	
	# Verificar transições
	if is_player_in_attack_range:
		# current_state = State.ATTACKING
		attack_cooldown = 0.0
		dash_timer = 0
		dir = Vector2.ZERO

	elif dash_timer >= dash_duration:
		# current_state = State.CHASING
		dash_timer = 0

func handle_attacking_state(delta: float):
	# Parar movimento durante o ataque
	body.velocity = Vector2.ZERO
	
	# Ataque cooldown
	attack_cooldown -= delta
	if attack_cooldown <= 0 and is_player_in_attack_range:
		player.take_knockback(last_dir, 10)
		player.take_damage(damage)
		attack_cooldown = attack_rate
	
	# Voltar para chase se player sair
	 #if not is_player_in_attack_range:
		# current_state = State.CHASING

func get_aniamtion_tipy():
	return 1 + (int(randf() * 4))

#func animation_logic():
	#
	#var play = ""
		#
	#if dir != Vector2.ZERO and not current_state == State.ATTACKING:
		#last_dir = dir
		#play += "walk"
	#else:
		#dir = last_dir
		#play += "idle"
		#
	#if dir.y < 0:
		#play += "_back"
		#
	#play += "_" + str(animation_type)
		#
	#anim.flip_h = dir.x > 0
	#
	#anim.play(play)
	
func animation_logic():
	if heath <= 0: return
	var play: String = ("idle" if current_state == EnemyState.WAITING else "walk") + "_"
	var dir: Vector2 = dir_to_player()
	play += ("back_" if dir.y < 0 else "") + str(animation_type)
	anim.flip_h = dir.x > 0
	anim.play(play)
	
func default_setup():
	atributes.append_array([
		damage_att, speed_att, heath_att
	])
	
	damage_att.setup(1, 1, "value")
	speed_att.setup(100, 150, "value")
	heath_att.setup(5, 15, "value")
	
	set_level(9, "max")

func _hit_play(player_body: Node2D) -> void:
	var player_area = player_body.get_parent() as Player
	if player_area:
		is_player_in_attack_range = true
		player = player_area

func _exit_player_area_attack(player_body: Node2D) -> void:
	var player_area = player_body.get_parent() as Player
	if player_area:
		is_player_in_attack_range = false

func _update_agent() -> void:
	agent.target_position = Globals.player_pos()
