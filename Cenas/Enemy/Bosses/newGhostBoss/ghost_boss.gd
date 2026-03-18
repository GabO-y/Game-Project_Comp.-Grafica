extends Boss

class_name _GhostBoss

@export var animated_slash_attack: AnimatedSprite2D
@export var slash_attack_area: Area2D
@export var touch_attack_area: Area2D
@export var timer_to_special_attack: Timer

# nos ataque especiais, o state, indica qual vai ser o ataque
# o stage indica o estagio do ataque, oq ele esta fazendo
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

var aux_var: Dictionary = {}

func _ready() -> void:
	super._ready()

	body.collision_layer = Globals.layers["boss"]
	body.collision_mask = Globals.layers["player"] | Globals.layers["weapon"]
	touch_attack_area.collision_layer = Globals.layers["boss"]
	touch_attack_area.collision_mask = Globals.layers["player"] | Globals.layers["weapon"]
	

func _process(delta: float) -> void:
	super._process(delta)
	if anim.animation != "laugh" and current_state != EnemyState.CUSTOM:
	#if anim.animation != "laugh":
		animation_logic()
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	

func waiting_state(delta: float):
	if t > d:
		setup_state(EnemyState.CHESING)
		return
	t += delta
	
func chesing_state(delta: float):
	if chase_player(30.0):
		setup_state(EnemyState.ATTACKING)
		return
	
func attacking_state(delta: float):
	if t > d:
		play_attack_animation()
		for body in slash_attack_area.get_overlapping_bodies():
			if body.get_parent() is Player:
				Globals.player.take_knockback(dir_to_player(), 20.0)
				Globals.player.take_damage(damage)
				break
		setup_state(EnemyState.WAITING)
		return
	t += delta
	
func custom_state(delta: float):
	match current_custom_state:
		CustomState.GHOST_RUN:
			ghost_run(special_stage, delta)
		CustomState.SHOOTING_GHOSTS:
			shooting_ghosts(special_stage, delta)
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
			if chase_player(70.0, 1.3):
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
				g.setup_custom_state(Ghost.CustomState.GHOST_RUN)
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
							player.take_knockback(g.dir_to_player(), 10.0)
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
				timer_to_special_attack.start()
				body.collision_layer = Globals.layers["boss"]
				body.collision_mask = Globals.layers["player"] | Globals.layers["weapon"]
				return

func shooting_ghosts(stage: int, delta: float):
	match stage:
		1:
			anim.play("laugh")
			await anim.animation_finished
			if special_stage > 1: return
			special_stage = 2
			animation_logic()
		2:
			var pos: Vector2 = Globals.room_manager.current_room.camera.global_position
			var dir: Vector2 = body.global_position.direction_to(pos)
			var dist: float = body.global_position.distance_to(pos)
			if dist < 1.0:
				special_stage = 3
			body.velocity = dir * speed
			body.move_and_slide()
		3:
			
			var i: int = aux_var["i"]
			var q: int = aux_var["ghost_quant"]

			if i >= q:
				special_stage = 4
				aux_var["time"] = 0
				aux_var["time_limit"] = 30
				aux_var["need_check"] = true
				return
			elif i in aux_var["random_not_angle"]:
				aux_var["i"] += 1
				return
				
			aux_var["time"] += 1
			if aux_var["time"] != aux_var["time_limit"]: return
			aux_var["time"] = 0
			
			var dir: Vector2 = Vector2.RIGHT.rotated(i * ((PI * 2) / q)) 
			
			body.velocity = dir
			aux_var["i"] += 1
			
			var g: Ghost = load("res://Cenas/Enemy/Ghost/Ghost.tscn").instantiate()
			aux_var["ghost_node"].add_child(g)
			g.special_stage = 1
			
			g.setup_state(EnemyState.CUSTOM)
			g.setup_custom_state(Ghost.CustomState.SHOOTING_GHOST)
			
			g.body.global_position = body.global_position
			g.body.scale *= 0.7
			g.speed = 200
			
			g.aux_var["dir"] = dir
			g.aux_var["dist"] = 0.1
			g.aux_var["can_continue"] = false
			
			aux_var["ghosts"].append(g)
		4:
			if aux_var["need_check"]:
				for g in aux_var["ghosts"]:
					if not g.aux_var["can_continue"]:
						return
			aux_var["need_check"] = false
		
			if aux_var["time"] < aux_var["time_limit"]:
				aux_var["time"] += 1
				return
					
			for g in aux_var["ghosts"]:
				g.special_stage = 2
			
			aux_var["time"] = 0
			aux_var["time_limit"] = 70
			special_stage = 5
		5:
		
			if aux_var["time"] < aux_var["time_limit"]:
				aux_var["time"] += 1
				return
				
			var g_node: Node2D = aux_var["ghost_node"]
			for ene in g_node.get_children():
				g_node.remove_child(ene)
				
			var q: int = aux_var["quant"]
				
			if q > 0:
				setup_custom_state(CustomState.SHOOTING_GHOSTS)
				aux_var["quant"] = q - 1
				special_stage = 3
				return
			remove_child(g_node)
		
			body.collision_layer = Globals.layers["boss"]
			body.collision_mask = Globals.layers["player"] | Globals.layers["weapon"]
			is_in_special = false
			timer_to_special_attack.start()
			setup_state(EnemyState.CHESING)

func dying_state(stage: int, delta: float):
	match stage:
		0: 
			if anim.animation != "partial_die":
				anim.play("partial_die")
			elif not anim.is_playing(): 
				custom_stage += 1
				anim.play("loop_partial_die")
		1:
			aux_var["frames"] += 1
			if aux_var["frames"] > aux_var["frames_limit"]:	
				Globals.item_manager.drop_by_name("Coin", body.global_position)
				aux_var["drop_coin_count"] += 1
				if aux_var["drop_coin_count"] >= aux_var["drop_coin_count_max"]:
					custom_stage += 1
		2:
			if Globals.house.already_finish:
				return
				
			Globals.house.already_finish = true
			anim.play("die")
			await anim.animation_finished
			Globals.house.finish_game.emit()
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
		CustomState.RANDOM_SPECIAL:
			timer_to_special_attack.wait_time = randf_range(7.0, 15.0)
			var r_state: CustomState = [
				CustomState.GHOST_RUN, CustomState.SHOOTING_GHOSTS
			].pick_random()
						
			body.collision_layer = Globals.layers["out_room_boss"]
			body.collision_mask = 0

			setup_custom_state(r_state)
			return
			
		CustomState.GHOST_RUN:
			special_stage = 1
		CustomState.SHOOTING_GHOSTS:
			special_stage = 1
			aux_var["quant"] = randi_range(1, 3)
			aux_var["ghost_node"] = Node2D.new()
			aux_var["ghost_quant"] = 60
			aux_var["i"] = 0
			aux_var["time_limit"] = 2
			aux_var["time"] = aux_var["time_limit"] - 1
			aux_var["ghosts"] = []
			var r_n_a: int = randi_range(0, aux_var["ghost_quant"] - 1)
			add_child(aux_var["ghost_node"])
			
			aux_var["random_not_angle"] = [r_n_a].map(
				func(i: int):
					var r: Array[int] = []
					for j in range(10):
						r.append(i + j)
					return r
			).get(0)
			
		CustomState.DYING:
			custom_stage = 0
			anim.play("partial_die")
			touch_attack_area.collision_layer = 0
			touch_attack_area.collision_mask = 0
			aux_var["drop_coin_count_max"] = 10
			aux_var["drop_coin_count"] = 0
			aux_var["frames"] = 0
			aux_var["frames_limit"] = 1
			t = 0.0
			d = 0.2
			timer_to_special_attack.stop()
			
	current_custom_state = state
	current_state = EnemyState.CUSTOM
	
func take_damage(damage):
	if is_dead: return
	super.take_damage(damage)
	if health <= 0:
		is_dead = true
		die()
		
func die():
	setup_custom_state(CustomState.DYING)


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
		player.take_knockback(dir_to_player(), 20.0)
		player.take_damage(1)

func _start_special_attack() -> void:
	timer_to_special_attack.stop()
	is_in_special = true
	setup_state(EnemyState.CUSTOM)
	setup_custom_state(CustomState.RANDOM_SPECIAL)

enum CustomState {RANDOM_SPECIAL, GHOST_RUN, SHOOTING_GHOSTS, DYING}
