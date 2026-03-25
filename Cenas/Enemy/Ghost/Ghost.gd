extends Enemy

class_name Ghost

var animation_type: int

var last_dir_player: Vector2

var voice_random_time: float = 1.0
var voice_timer: float = 0.0

enum State {
	CHASE,
	PREPARE_ATTACKING,
	DASHING,
	SPECIAL
}

@export var area_hit: Area2D
@export var screen_notifier: VisibleOnScreenNotifier2D

# new 

@export var animated_slash_attck: AnimatedSprite2D
@export var slash_attack_area: Area2D

var current_custom_state: CustomState
var special_stage: int = 1

var aux_var: Dictionary = {}

func _ready() -> void:
	super._ready()
	animation_type = randi_range(1, 4)
	body.collision_layer = Globals.layers["ghost"]
	body.collision_mask = Globals.layers["player"] | Globals.layers["weapon"]

func _process(delta: float) -> void:
	animation_logic()
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
func waiting_state(_delta: float):
	if wait_frames_count > wait_frames_duration:
		setup_state(EnemyState.CHASING)
		return
	wait_frames_count += 1
	
func chasing_state(delta: float):
	if dist_to_player() < 15.0:
		setup_state(EnemyState.ATTACKING)
		return
	body.velocity = dir_to_player() * speed
	body.move_and_slide()
		
func attacking_state(delta: float):
	if take_damage_frames_count > take_damage_coldown_frames:
		play_attack_animation()		
		for body in slash_attack_area.get_overlapping_bodies():
			if body.get_parent() is Player:
				Globals.player.take_damage(damage)
		setup_state(EnemyState.WAITING)
		return
	take_damage_frames_count += 1


func custom_state(delta: float):
	match current_custom_state:
		CustomState.GHOST_RUN:
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
		CustomState.SHOOTING_GHOST:
			match special_stage:
				1:
					if aux_var["dist"] <= 0.0:
						aux_var["can_continue"] = true
						return
					body.velocity = aux_var["dir"] * speed
					body.move_and_slide()
					aux_var["dist"] -= delta
				2:
					body.velocity = aux_var["dir"] * speed
					body.move_and_slide()
					
func setup_state(state: EnemyState, d: float = -1.0, t: float = -1.0):
	match state:
		EnemyState.WAITING:
			wait_frames_count = 0
		EnemyState.ATTACKING:
			take_damage_frames_count = 0
		EnemyState.CUSTOM:
			special_stage = 1
			t = 0.0
			# d é modificado no boss
	if t > -1: self.t = t
	if d > -1: self.d = d
		
	current_state = state

func setup_custom_state(state: CustomState):
	match state:
		CustomState.GHOST_RUN:
			pass
		CustomState.SHOOTING_GHOST:
			pass
	current_custom_state = state

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

func animation_logic():
	if heart <= 0: return
	var play = "type_" + str(animation_type)
	if body.velocity.y < 0:
		play = "back" + str("" if(
			animation_type % 2 != 0
		) else "_bald") 
	anim.flip_h = body.velocity.x > 0
	anim.play(play)
	
func setup_status():
	attributes = {
		"heart": SimpleAttribute.new(20, 5, 9),
		"damage": SimpleAttribute.new(3, 1, 9),
		"speed": SimpleAttribute.new(120.0, 100.0, 9),
		"wait_frames": SimpleAttribute.new(30, 40, 9),
		"take_damage": SimpleAttribute.new(1, 5, 9)
	}
	update_all_status()

func die():
	super.die()
	area_hit.collision_layer = 0
	area_hit.collision_mask = 0

enum CustomState {GHOST_RUN, SHOOTING_GHOST}

	
