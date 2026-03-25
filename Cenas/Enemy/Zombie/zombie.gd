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
	animation_type = get_aniamtion_tipy()
	super._ready()
	

func _process(delta: float) -> void:
	animation_logic()
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func waiting_state(delta: float):
	if wait_frames_count > wait_frames_duration:
		if dist_to_player() < 20.0:
			setup_state(EnemyState.ATTACKING, 0.5)
			return
		setup_state(EnemyState.CHASING)
		return
	wait_frames_count += 1
	
func chasing_state(delta: float):
	if dist_to_player() < 50.0:
		setup_state(EnemyState.DASHING)
		return
	agent.target_position = Globals.player_pos()
	var next_p: Vector2 = agent.get_next_path_position()
	body.velocity = body.global_position.direction_to(next_p) * speed
	body.move_and_slide()
	
func dashing_state(delta: float):
	if t > d or dist_to_player() < 20.0:
		setup_state(EnemyState.ATTACKING)
		return
	body.velocity = last_dir_player * speed * 1.3
	body.move_and_slide()
	t += delta

func attacking_state(delta: float):
	if take_damage_frames_count > take_damage_coldown_frames:
		setup_state(EnemyState.WAITING)
		play_attack_animation()
		for body in slash_hit_area.get_overlapping_bodies():
			if body.get_parent() is Player:
				Globals.player.take_damage(damage)
		return
	take_damage_frames_count += 1
	
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
			wait_frames_count = 0
		EnemyState.DASHING:
			last_dir_player = dir_to_player()
			self.t = 0.0
			self.d = 0.3
		EnemyState.ATTACKING:
			take_damage_frames_count = 0
	if t > -1: self.t = t
	if d > -1: self.d = d
		
	current_state = state

func get_aniamtion_tipy():
	return 1 + (int(randf() * 4))

func animation_logic():
	if heart <= 0: return
	var play: String = ("idle" if current_state == EnemyState.WAITING else "walk") + "_"
	var dir: Vector2 = dir_to_player()
	play += ("back_" if dir.y < 0 else "") + str(animation_type)
	anim.flip_h = dir.x > 0
	anim.play(play)

func setup_status():
	attributes = {
		"heart": SimpleAttribute.new(20, 5, 9),
		"damage": SimpleAttribute.new(5, 1, 9),
		"speed": SimpleAttribute.new(150.0, 100.0, 9),
		"wait_frames": SimpleAttribute.new(30, 40, 9),
		"take_damage": SimpleAttribute.new(1, 5, 9)
	}
	update_all_status()
