extends Boss

class_name _GhostBoss

@export var animated_slash_attack: AnimatedSprite2D
@export var slash_attack_area: Area2D
@export var touch_attack_area: Area2D

# nos ataque especiais, o state, indica qual vai ser o ataque
# o stage indica o estagio do ataque, oq ele esta fazendo
var current_special_state: SpecialState
var special_stage: int = 0

var current_custom_state: CustomState
var custom_stage: int = 0

@export var time_to_special: float = 10.0
var timer_special: float = 0.0

var is_in_special: bool = false
var last_player_dir: Vector2 = Vector2.ZERO

var drop_item_count: int = 0
var drop_item_max: int = 50

### variaveis relativas ao GHOST RUN 
var quant_ghosts: int = 10
####################################

func _ready() -> void:
	super._ready()
	body.collision_layer = Globals.layers["boss"]
	body.collision_mask = Globals.layers["player"] | Globals.layers["armor"]
	touch_attack_area.collision_layer = Globals.layers["boss"]
	touch_attack_area.collision_mask = Globals.layers["player"] | Globals.layers["armor"]

func _process(delta: float) -> void:
	super._process(delta)
	if anim.animation != "laugh" and current_state != EnemyState.CUSTOM:
		animation_logic()
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_in_special and health > 0:
		if timer_special > time_to_special:
			is_in_special = true
			setup_custom_state(CustomState.SPECIAL)
		timer_special += delta

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
	
func custom_state(delta: float):
	match current_custom_state:
		CustomState.SPECIAL:
			match current_special_state:
				SpecialState.GHOST_RUN:
					ghost_run(special_stage, delta)
		CustomState.DYING:
			dying_state(custom_stage, delta)

func ghost_run(stage: int, delta: float):
	match stage:
		1:
			anim.play("laugh")
			await anim.animation_finished
			if special_stage > 1: return
			special_stage = 2
			animation_logic()
		2:
			if chase_player(50.0, 1.3):
				special_stage += 1
				last_player_dir = dir_to_player()
		3:
			body.velocity = last_player_dir * speed * 1.3
			body.move_and_slide()
		4:
			var s_size: Vector2 = get_viewport_rect().size
			var d: float = 1.0
			for i in range(quant_ghosts):
				# spawna o fantasma
				var g: Ghost = load("res://Cenas/Enemy/Ghost/Ghost.tscn").instantiate()
				add_child(g)
				# com o tamanho da tela, o maiorvalor de x e y (geralmente)
				# x, vira um raio, onde o fantasma vai nascer dentro desse raio
				# q componhe 40% da tela, garantindo q ele fique fora da tela
				var r: float = max(s_size.x, s_size.y)
				g.speed = 100.0
				g.d = d + (0.3 * i)
				g.global_position = Globals.player_pos() + Globals.get_random_dir() * r * 0.4
				g.setup_state(EnemyState.CUSTOM)
				var area: Area2D = Area2D.new()
				var collision_shape: CollisionShape2D = CollisionShape2D.new()
				var shape: CircleShape2D = CircleShape2D.new()
				shape.radius = 10.0
				collision_shape.debug_color = Color.RED
				collision_shape.shape = shape		
				g.body.add_child(area)
				area.add_child(collision_shape)
				area.collision_layer = Globals.layers["enemy"]
				area.collision_mask = Globals.layers["player"]
				area.name = "ghost_area_special"
				area.body_entered.connect(
					func(body):
						var player: Player = body.get_parent() as Player
						if player:
							player.take_damage(1)
				)
			special_stage += 1
			t = 0.0
			self.d = d + (0.3 * quant_ghosts) * 2
		5:
			if t > d:
				special_stage += 1
				body.global_position = Globals.player_pos() + get_viewport_rect().size.x * 0.4 * Globals.get_random_dir()
			t += delta
		6:
			if chase_player(30.0, 1.3):
				setup_state(EnemyState.ATTACKING)
				is_in_special = false
				timer_special = 0.0
				body.collision_layer = Globals.layers["boss"]
				body.collision_mask = Globals.layers["player"]
				return

func dying_state(stage: int, delta: float):
	match stage:
		0: 
			if not anim.is_playing(): 
				custom_stage += 1
				anim.play("loop_partial_die")
		1:
			t += delta
			if t > d:
				t = 0.0
				Globals.item_manager.drop_by_name("coin", body.global_position)
				drop_item_count += 1
				if drop_item_count >= drop_item_max:
					custom_stage += 1
		2:
			anim.play("die")
			await anim.animation_finished
			Globals.room_manager.current_room.finish = true
			Globals.room_manager._clear_effects()
			queue_free()
			
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
	
func setup_custom_state(state: CustomState, idx: int = 0):
	match state:
		CustomState.SPECIAL:
			time_to_special = randf_range(10.0, 20.0)
			match idx:
				0:
					special_stage = 1
					current_special_state = randi_range(0, SpecialState.size() - 1)
					body.collision_layer = Globals.layers["out_room_boss"]
					body.collision_mask = 0
		CustomState.DYING:
			anim.play("partial_die")
			touch_attack_area.collision_layer = 0
			touch_attack_area.collision_mask = 0
			t = 0.0
			d = 0.2
	current_custom_state = state
	current_state = EnemyState.CUSTOM
	
func take_damage(damage):
	if is_dead: return
	super.take_damage(damage)
	if health <= 0:
		is_dead = true
		setup_custom_state(CustomState.DYING)
		
func die():
	pass

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

func _when_boss_exit_screen() -> void:
	if is_in_special and special_stage == 3: 
		special_stage += 1
		
func _on_touch_attack_area_body_entered(body: Node2D) -> void:
	var player: Player = body.get_parent() as Player
	if player:
		player.take_damage(1)


enum CustomState {SPECIAL, DYING}
enum SpecialState {GHOST_RUN}
