extends Enemy

class_name MegaGhost

@export var attack_area: Area2D
@export var attack_collision: CollisionPolygon2D
@export var form_attack: Node2D
@export var timer: Timer
@export var is_stop: bool
@export var life_bar: ProgressBar
@export var damage_bar: ProgressBar
@export var timer_damage_bar: Timer
@export var vertical_mid_spawn_1: Marker2D
@export var vertical_mid_spawn_2: Marker2D
@export var horizontal_mid_spawn_1: Marker2D
@export var horizontal_mid_spawn_2: Marker2D
@export var center_to_split: Marker2D
@export var locals: LocalVar

#pra verificar se esta dando o ataque especial
var on_special_attack = false
# quando um ataque especial começa, e para que certas funcs nao sejam chamadas diversas vezes
# enquanto esta rolando o especial
var start_special = false
# quando esta esta, essa vira sua nova variavel momentania que controlará
# sua direção
var dir_special_attack: Vector2
# quando o boss entra no ataque "ghost run", ele primeiro vai em sua direção, mas dps
# de uma distancia, ele so continua indo para frente, isso que define se é so pra ele continuar
var is_continue_toward = false
# fica com a ultima direção que o boss estava, para quando o is_continue_toward for true, ele
# ter essa direção para seguir
var last_dir_special: Vector2
# quando ele esta num especial, a movimentação padrao muda, nisso, a velocidade tbm
# controlado por essa variavel 
var speed_special_attack: int = 100
# verificador para atualizar a barra de dono
var is_update_damage_bar = false
# Quando a barra de damage esta descendo, ela vai descer ate esse last
var last_life
# Qual o ataque especial que esta rolando
var current_special_attack: String
# para verificar se esta na area do ataque 1
var is_player_on_attack_area_1 = false
# pra nao ficar dando consecutivos danos toda vez que o player esta na area 
# do boss
var finish_attack = true
# guarda o nome da ultima parade com que colidiu, para o
# ataque de "crash_wall"

var last_wall_collide: String
var times_crash_wall = 1
var already_split = false
var is_split = false
var type_split = "mid"
var ene_in_crash_attack: Array[Enemy]
var emerge_boos = false

var collision_special = 2

# todos os ataques especias
var all_special_attacks = [
	"ghosts_run",
	"crash_wall"
]

var available_special_attacks: Array[String]

func _ready() -> void:
	
	
		
	#Globals.connect_safe(locals.emerge_boss, _on_locals_emerge_boss)
	
	attack_area.body_entered.connect(_entrered_attack_area)
	attack_area.body_exited.connect(_exit_attack_area)
	
	is_active = true
	
	for attack in all_special_attacks:
		available_special_attacks.append(attack)

	super._ready()
	
func _process(delta: float) -> void:
	
	if emerge_boos:
		if modulate.a < 1:
			modulate.a += 0.1
			
		if modulate.a >= 1:
			await Globals.time(0.5)
			refrash_setup()
			emerge_boos = false
	
	super._process(delta)
	update_bar()
	
	if is_player_on_attack_area_1:
		slash(Globals.player)
	
	if is_update_damage_bar:			
		damage_bar.value -= 0.4
		if damage_bar.value == last_life:
			is_update_damage_bar = false

func _physics_process(delta: float) -> void:
		
	if is_stop: return

	if on_special_attack:
		move_special()
		return

	var pla_pos = Globals.player.player_body.global_position
	var ene_pos = body.global_position
	
	dir = ene_pos.direction_to(pla_pos).normalized()
		
	if dir == null or ene_pos.distance_to(pla_pos) < 50:
		dir = Vector2.ZERO
	
	body.velocity = dir * speed
	body.move_and_slide()
		
func slash(player: Player):	
	
	if is_running_attack or on_special_attack: return
		
	var dir = body.global_position.direction_to(player.player_body.global_position).normalized()
	attack_collision.rotation = (dir.angle() - PI/1.5)
	form_attack.rotation = (dir.angle() - PI/1.5)
	
	if !finish_attack: return
	finish_attack = false
	speed *= 0.9
	
	
	
	await get_tree().create_timer(1.5).timeout
	
	
	form_attack.visible = true
	finish_attack = true
	
	speed *= 1.1
		
	if is_player_on_attack_area_1: 
		Globals.player.take_damage(damage)
		var knockback_dir = -(Globals.player.player_body.global_position.direction_to(body.global_position))
		Globals.player.take_knockback(knockback_dir , 200)
	
	await get_tree().create_timer(0.1).timeout
	form_attack.visible = false
			
func _entrered_attack_area(body):
	if body.get_parent() is not Player: return
	is_player_on_attack_area_1 = true
		
func _exit_attack_area(body):
	if body.get_parent() is not Player: return
	is_player_on_attack_area_1 = false
		
func start_special_attack():
	
	if start_special: return 	
	
	is_stop = true
	start_special = true

	await Globals.time(2)
	
	is_stop = false
	on_special_attack = true

	current_special_attack = get_random_special_attack()
	print(current_special_attack)
	print(speed_special_attack)	
	
#	Verificar pq o ghost run nao esta funcionando
	
	match current_special_attack:
		"ghosts_run":
			attack_ghost_run()
		"crash_wall":
			start_attack_crash_wall()
	
func attack_ghost_run():
	
	body.collision_layer = 1 << 5
	body.collision_mask = 1 << 5

	is_running_attack = true

func start_attack_crash_wall():
		
	speed_special_attack = 100
	
	body.collision_layer = 1 << 2
	body.collision_mask = 1 << 2
	
	is_running_attack = true
	
	speed_special_attack = 2
	
	var dialgonal_dir = [
		Vector2( 1, -1),
		Vector2( 1,  1),
		Vector2(-1,  1),
		Vector2(-1, -1)
		].pick_random()
		
		
	dir_special_attack = dialgonal_dir
	ene_in_crash_attack.append(self)

func move_special():
	
	if is_stop: return
		
	match current_special_attack:
		"ghosts_run":
			move_ghosts_run()
		"crash_wall":
			move_crash_wall()
			
func move_ghosts_run():
	
	dir_special_attack = body.global_position.direction_to(Globals.player.player_body.global_position)
	
	if body.global_position.distance_to(Globals.player.player_body.global_position) < 60:
		dir_special_attack = Vector2.ZERO
		is_continue_toward = true
		
	if dir_special_attack == Vector2.ZERO or is_continue_toward:
		dir_special_attack = last_dir_special
	else:
		last_dir_special = dir_special_attack
	
	body.velocity = dir_special_attack * speed_special_attack
	body.move_and_slide()
	
func move_crash_wall():
	
	var collsiion = body.move_and_collide(dir_special_attack * speed_special_attack)
		
	if collsiion:
		var collider = collsiion.get_collider()
			
		if collider is TileMapLayer:
						
			dir_special_attack = Globals.dir_possibles_crash_wall[dir_special_attack].get(last_wall_collide,
				-dir_special_attack
			)
			
			if times_crash_wall != 0 and times_crash_wall % 2 == 0 and not already_split:
				split_when_crash()
				already_split = true
			else:
				times_crash_wall += 1

func split_when_crash():
	
#		Esse é o split do big (que gera dois mid)
	
		var first_part = load("res://Cenas/Enemie/Bosses/MegaGhost/Parts/MidPart/MidPart.tscn").instantiate() as Part
		var second_part = load("res://Cenas/Enemie/Bosses/MegaGhost/Parts/MidPart/MidPart.tscn").instantiate() as Part
	
		ene_in_crash_attack.erase(self)

		add_child(first_part)
		add_child(second_part)
		
		first_part.locals = locals
		second_part.locals = locals
		
		first_part.center_pos = center_to_split.global_position
		second_part.center_pos = center_to_split.global_position
				
		ene_in_crash_attack.append(first_part)
		ene_in_crash_attack.append(second_part)
		
		for ene in ene_in_crash_attack:
			
			ene = ene as Part
						
			ene.show()
			
			ene.dir_special_attack = dir_special_attack
			ene.speed_special_attack = speed_special_attack
			ene.last_wall_collide = last_wall_collide
			
			ene.body.collision_mask = 1 << 2
			ene.body.collision_layer = 1 << 2
			
			ene.set_collision_layer_ray(3)
			
		match last_wall_collide:
			"down", "up":
				first_part.body.global_position = vertical_mid_spawn_1.global_position
				second_part.body.global_position = vertical_mid_spawn_2.global_position
			"left", "right":
				first_part.body.global_position = horizontal_mid_spawn_1.global_position
				second_part.body.global_position = horizontal_mid_spawn_2.global_position

		second_part.dir_special_attack = -dir_special_attack

		is_active = false
		body.hide()
		
		body.collision_layer = 0
		body.collision_mask = 0

func refrash_setup():
	body.collision_layer = 1
	body.collision_mask = 1 
	start_special = false
	on_special_attack = false
	timer.stop()
	timer.start()
	is_stop = false
	is_running_attack = false
	is_continue_toward = false
	times_crash_wall = 0
	is_active = true
	already_split = false
	speed_special_attack = 100
	
func _player_enter_while_running(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if player == null: return
	if is_running_attack:
		player.take_damage(damage)
		
func update_bar():
	if life_bar == null: return
	life_bar.value = life
	pass
	
func take_damage(damage: int):
	if life - damage <= 0:
		life = 0
	is_update_damage_bar = false
	_take_damages.emit()
	super.take_damage(damage)

func _update_damage_bar() -> void:
	is_update_damage_bar = true
	last_life = life
	timer_damage_bar.stop()

func _start_timer_damage_bar() -> void:
	timer_damage_bar.start()

func _start_special_attack() -> void:
	start_special_attack()

func apply_special_damage(pla: Player):
	if finish_attack: return
	pla.take_damage(damage)
	finish_attack = false

func _player_exit_area(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if player == null: return
	finish_attack = true

func _on_rays_to_wall_crash_with(wall_name: String) -> void:
	last_wall_collide = wall_name

func _on_locals_emerge_boss() -> void:
	
	body.global_position = center_to_split.global_position
	body.show()
	is_stop = true
	modulate.a = 0
	emerge_boos = true

func _on_locals_free_all() -> void:
	
	for ene in ene_in_crash_attack:
		
		if not is_instance_valid(ene): return
		
		if ene is MidPart:
			ene.queue_free()
			
	ene_in_crash_attack.clear()
	
func get_random_special_attack():
	if available_special_attacks.is_empty():
		for attack in all_special_attacks:
			available_special_attacks.append(attack)
		return get_random_special_attack()

	var attack = available_special_attacks.pick_random()
	available_special_attacks.erase(attack)
	return attack

signal _take_damages
