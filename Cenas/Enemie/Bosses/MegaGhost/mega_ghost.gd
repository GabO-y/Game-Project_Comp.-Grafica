extends Enemy

class_name MegaGhost

@export var attack_area: Area2D
@export var attack_collision: CollisionPolygon2D
@export var form_attack: Node2D
@export var timer: Timer
@export var is_stop: bool

#pra verificar se esta dando o ataque especial
var on_special_atack = false
var start_special = false
var dir_special_attack: Vector2
var speed_special_attack: int = 200

#para verificar se esta na area do ataque 1
var is_player_on_attack_area_1 = false

#pra nao ficar dando consecutivos danos toda vez que o player esta na area 
#do boss
var finish_attack = true

func _ready() -> void:
	
	attack_area.body_entered.connect(_on_body_entered)
	attack_area.body_exited.connect(_exit_attack_area)

	super._ready()
	
func _process(delta: float) -> void:
	
	super._process(delta)
	
	if is_player_on_attack_area_1:
		slash(Globals.player)

func _physics_process(delta: float) -> void:
	
	if on_special_atack:
		attack_fantasm_run()
		move_special()
			
		return
	
	if is_stop: return
	
	var pla_pos = Globals.player.player_body.global_position
	var ene_pos = body.global_position
	
	dir = ene_pos.direction_to(pla_pos).normalized()
	
	if dir == null or ene_pos.distance_to(pla_pos) < 50:
		dir = Vector2.ZERO

	body.velocity = dir * speed
	body.move_and_slide()
		
func slash(player: Player):	
		
	var dir = body.global_position.direction_to(player.player_body.global_position).normalized()
	attack_collision.rotation = (dir.angle() - PI/1.5)
	form_attack.rotation = (dir.angle() - PI/1.5)
	
	if not finish_attack: return
	finish_attack = false
	
	await get_tree().create_timer(1.5).timeout
	form_attack.visible = true
	finish_attack = true
	attack()
	await get_tree().create_timer(0.1).timeout
	form_attack.visible = false
			
func _on_body_entered(body):
	if body.get_parent() is not Player: return
	is_player_on_attack_area_1 = true
		
func _exit_attack_area(body):
	if body.get_parent() is not Player: return
	is_player_on_attack_area_1 = false
	
func attack():
	if not is_player_on_attack_area_1: return
	Globals.player.take_damage(damage)
	
	var dir = (Globals.player.player_body.global_position.direction_to(body.global_position))

	Globals.player.take_knockback(dir , 2500)

func attack_fantasm_run():
	
	if start_special: return
	
	running_attack = true
	is_stop = true
	start_special = true

	await get_tree().create_timer(1).timeout
	
	is_stop = false
	
	body.collision_layer = 1 << 5
	body.collision_mask = 1 << 5
	
	print(body.collision_layer)
	print(body.collision_mask)
	
	on_special_atack = true
	
	var index_dir = int(randf() * 4)
	
	match index_dir:
		0: dir_special_attack = Vector2.UP
		1: dir_special_attack = Vector2.DOWN
		2: dir_special_attack = Vector2.LEFT
		3: dir_special_attack = Vector2.RIGHT
		
func move_special():
	
	if is_stop: return
	
	body.velocity = dir_special_attack * speed_special_attack
	body.move_and_slide()
	
func _on_timer_timeout() -> void:
	init_special_attack()
	
func init_special_attack():
	
	if on_special_atack: return
	on_special_atack = true
	
	pass

func refrash_setup():
	body.collision_layer = 1
	body.collision_mask = 1 
	start_special = false
	on_special_atack = false
	timer.stop()
	timer.start()
	is_stop = false
	running_attack = false
	
