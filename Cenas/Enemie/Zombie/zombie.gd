extends Enemy

class_name Zombie

@export var agent: NavigationAgent2D
@export var time: Timer

enum State { CHASING, DASHING, ATTACKING }
var current_state: State = State.CHASING

var dash_timer = 0.0
var dash_duration = 0.5
var dash_direction: Vector2
var dash_speed = 100

var animation_tipy: int

var attack_cooldown = 0.0
var attack_rate = 1.5

var is_player_in_attack_range = false

func _ready() -> void:
	
	z_index = 1
	animation_tipy = get_aniamtion_tipy()

	super._ready()

func _process(delta: float) -> void:
	animation_logic()
	super._process(delta)

func _physics_process(delta: float) -> void:
	
	if !is_active or is_stop:
		return
				
	var player_pos = Globals.player.player_body.global_position
	var distance_to_player = body.global_position.distance_to(player_pos)
		
	match current_state:
		State.CHASING:
			handle_chasing_state(distance_to_player, player_pos)
		State.DASHING:
			handle_dashing_state(delta, distance_to_player)
		State.ATTACKING:
			handle_attacking_state(delta)

func handle_chasing_state(distance_to_player: float, player_pos: Vector2):

	var next_point = agent.get_next_path_position() 
	dir = body.global_position.direction_to(next_point).normalized()
	body.velocity = dir * speed
	body.move_and_slide()
	
	if distance_to_player < 40:
		is_stop = true
		await Globals.time(0.2)
		is_stop = false
		
		current_state = State.DASHING
		dash_direction = dir
		dash_timer = 0.0

func handle_dashing_state(delta: float, distance_to_player: float):
	dash_timer += delta
	
	# Executar dash
	body.velocity = dash_direction * dash_speed
	body.move_and_slide()
	
	# Verificar transições
	if is_player_in_attack_range:
		current_state = State.ATTACKING
		attack_cooldown = 0.0
		dash_timer = 0
		dir = Vector2.ZERO

	elif dash_timer >= dash_duration:
		current_state = State.CHASING
		dash_timer = 0

func handle_attacking_state(delta: float):
	# Parar movimento durante o ataque
	body.velocity = Vector2.ZERO
	
	# Ataque cooldown
	attack_cooldown -= delta
	if attack_cooldown <= 0 and is_player_in_attack_range:
		player.take_damage(damage)
		attack_cooldown = attack_rate
	
	# Voltar para chase se player sair
	if not is_player_in_attack_range:
		current_state = State.CHASING

func get_aniamtion_tipy():
	return 1 + (int(randf() * 4))

func animation_logic():
	
	var play = ""
		
	if dir != Vector2.ZERO and not current_state == State.ATTACKING:
		last_dir = dir
		play += "walk"
	else:
		dir = last_dir
		play += "idle"
		
	if dir.y < 0:
		play += "_back"
		
	play += "_" + str(animation_tipy)
		
	anim.flip_h = dir.x > 0
	
	anim.play(play)
	
func _hit_play(body: Node2D) -> void:
	var player_area = body.get_parent() as Player
	if player_area:
		is_player_in_attack_range = true
		player = player_area

func _exit_player_area_attack(body: Node2D) -> void:
	var player_area = body.get_parent() as Player
	if player_area:
		is_player_in_attack_range = false

func _update_agent() -> void:
	agent.target_position = Globals.player.body.global_position
	pass
