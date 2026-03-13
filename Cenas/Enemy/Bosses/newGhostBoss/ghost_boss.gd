extends Boss

class_name _GhostBoss

@export var animated_slash_attack: AnimatedSprite2D
@export var slash_attack_area: Area2D

func _ready() -> void:
	super._ready()
	body.collision_layer = Globals.layers["boss"]
	body.collision_mask = Globals.layers["player"] | Globals.layers["armor"]

func _process(delta: float) -> void:
	super._process(delta)
	animation_logic()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
func waiting_state(delta: float):
	if t > d:
		setup_state(EnemyState.CHESING)
		return
	t += delta
	
func chesing_state(delta: float):
	if dist_to_player() < 25.0:
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
				break
		setup_state(EnemyState.WAITING)
		return
	t += delta
	
func setup_state(state: EnemyState, d: float = -1.0, t: float = -1.0):
	match state:
		EnemyState.ATTACKING:
			self.t = 0.0
			self.d = 0.1
		EnemyState.WAITING:
			self.t = 0.0
			self.d = 1.0
	if d > -1.0: self.d = d
	if t > -1.0: self.t = t
	current_state = state

func animation_logic():
	var play: String = "walk"
	if body.velocity.y < 0:
		play += "_back"
	anim.flip_h = body.velocity.x < 0	
	anim.play(play)

func play_attack_animation():
		
	if animated_slash_attack.visible: return

	animated_slash_attack.visible = true
	
	var dir: Vector2 = dir_to_player()
	
	animated_slash_attack.rotation = 0.0
	animated_slash_attack.rotation = dir.angle()

	animated_slash_attack.global_position += dir * 20
		
	animated_slash_attack.play("attack")
	setup_state(EnemyState.WAITING)

	await animated_slash_attack.animation_finished
	
	animated_slash_attack.visible = false
	animated_slash_attack.global_position = body.global_position
