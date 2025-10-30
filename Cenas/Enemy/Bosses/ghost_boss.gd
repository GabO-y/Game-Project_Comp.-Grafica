extends Enemy
class_name GhostBoss

enum State {CHASING, SPECIAL, STOPED, PREPERE_ATTACK}
var current_state: State

@export var slash_node: Node2D
@export var slash_node_timer: Timer

var is_prepere_attack: bool = false
var prepere_attack_duration: float = 1
var prepere_attack_timer: float = 0.0
var is_player_area_attack: bool = false
# quando player entra na area, o boss entra em modo de ataque, 
# caso a varivel seja true, msm que o player saia da area, ele ainda 
# vai esperar dar o ataque
var wait_attack_finish: bool = true

func _ready() -> void:
	speed = 100
	setup()
	set_active(true)

func _process(delta: float) -> void:
	_animation_logic()
	
func _physics_process(delta: float) -> void:
	
	if not is_active: return
			
	match current_state:
		
		State.CHASING:
			chase_move()
		State.STOPED: 
			if is_prepere_attack:
				prepere_attack_logic(delta)
				return
			if dist_to_player() > 40:
				current_state = State.CHASING

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
	current_state = State.CHASING
	slash_node.visible = false
	
func chase_move():
	
	if is_player_area_attack and dist_to_player() <= 40:
		prepare_attack()
		return
		
	dir = dir_to_player()	
	body.velocity = dir * speed
	body.move_and_slide()

func prepare_attack():
	current_state = State.STOPED
	is_prepere_attack = true
	prepere_attack_timer = 0
	prepere_attack_duration = 1
	wait_attack_finish = true
	
func prepere_attack_logic(delta: float):
	# logica basica, para ficar parado um tempinho,
	# dps atacar
	prepere_attack_timer += delta
	
	if prepere_attack_timer >= prepere_attack_duration:
		# se o player permanecer na area de ataque, msm
		# dps dele já ter atacado, ele não desativa a varievel,
		# apenas aumenta a duração pro proximo ataque
		if is_player_area_attack:
			prepare_attack()
			prepere_attack_duration = 2
			wait_attack_finish = false
		else: 
			is_prepere_attack = false

		slash(dir_to_player())

func slash(dir: Vector2):
	slash_node.visible = true
	var angle = dir.angle() - PI/4
	slash_node.rotation = angle
	slash_node_timer.start()
	
	if is_player_area_attack:
		Globals.player.take_knockback(dir, 20)
		Globals.player.take_damage(damage)

func _on_timer_to_hide_view_timeout() -> void:
	slash_node.visible = false
	
func _on_slash_player_body_entered(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if !player: return
	is_player_area_attack = true

func _on_slash_area_player_body_exited(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if !player: return
	
	if not wait_attack_finish:
		current_state = State.CHASING
		
	is_player_area_attack = false
