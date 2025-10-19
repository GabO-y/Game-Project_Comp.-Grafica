extends Enemy

class_name Ghost

var animation_type: int
var mouse_pos: Vector2

# Variaveis referentes ao ataque
var is_attacking = false
var time_attack = 0.5;
var timer_attack = 0
var speed_when_attack = 2
var last_dir_player: Vector2
var check_on_collision = false
var is_continue_toward = false

var special_attack = ""

func _ready() -> void:
		
	animation_type = int(randf() * 4) + 1
	
	if animation_type == 4:
		animation_type = 3
							
	anim.show()
	
	damage = 5
	life = 5
		
	super._ready()
	
	player = get_tree().get_first_node_in_group("player") 

func _process(delta: float) -> void:
	
	if is_stop: return
	
	if not special_attack.is_empty():
		match special_attack:
			"ghosts_run":
				ghosts_run_move()
		return
	
	var dist = body.global_position.distance_to(player.player_body.global_position)
	
	if dist < 30:
		await Globals.time(0.5)
		is_attacking = true
		body.collision_layer = Globals.collision_map["no_player_but_damage"]
		
	if check_on_collision:
		if dist >= 30:
			refrash()
			check_on_collision = false
		
	animation_logic()
	
	if is_attacking:
		dash_slash(delta)
		
	if is_running_attack:
		running_player()
	else:
		chase_player()
		
	super._process(delta)
	
func animation_logic():
	
	if atack_player: return
	
	var play := ""
	
	var dir_anim: Vector2

	if dir == Vector2.ZERO: 
		dir_anim = last_dir
	else: 
		dir_anim = dir
	
	if dir_anim.x > 0:
		play = "right"
	else:
		play = "left"
	
	if dir_anim.y < 0:
		play += "_back"
		
	if play.contains("back"):
		if (animation_type == 2 || animation_type == 4) and play.contains("back"):
			play += "_bald"
	else:
		play += str(animation_type)
					
	anim.play(play)

func dash_slash(delta: float):
	
	var ene_pos = body.global_position
	var pla_pos = player.player_body.global_position

	if (timer_attack >= time_attack):
		await Globals.time(0.5)
		is_attacking = false
		timer_attack = 0
		check_on_collision = true
		return
	
	var dir
	
	if ene_pos.distance_to(pla_pos) < 15:
		dir = last_dir_player
	else:
		dir = ene_pos.direction_to(pla_pos).normalized()
		last_dir_player = dir
		
	body.velocity += dir * speed_when_attack
	body.move_and_slide()
	
	timer_attack += delta
	
func chase_player():
	
	if is_attacking: return
	
	var ene_pos = body.global_position
	var pla_pos = player.player_body.global_position
	
	var distance = ene_pos.distance_to(pla_pos)
	
	if !is_active or player == null:
		dir = Vector2.ZERO
	else:
		dir = (pla_pos - ene_pos).normalized()
		last_dir = dir
		
	body.velocity = dir * speed
	
	body.move_and_slide()
	
func enable():
	show()
	is_active = true
	refrash()
	
func running_player():
	pass

func _player_enter_hit(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if player == null: return
	player.take_damage(damage)

func refrash():
	body.collision_layer = Globals.collision_map["enemy"]
	body.collision_mask = Globals.collision_map["enemy"]
	
func ghosts_run_move():
	
	var ene_pos = body.global_position
	var pla_pos = Globals.player.player_body.global_position
	
	var dist = ene_pos.distance_to(pla_pos)
	dir = ene_pos.direction_to(pla_pos)
	
	if dist <= 40 or is_continue_toward:
		dir = last_dir_player
		is_continue_toward = true
	else:
		last_dir_player = dir
	
	body.velocity = dir * speed
	body.move_and_slide()
		
