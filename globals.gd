extends Node

var current_room: Room
var last_scene
var can_teleport = true
var player: Player
var die = false
var already_keys = []
var is_get_animation = false
var center_pos: Vector2
var special_time_ghost_run = 2
var player_pos: Vector2
var curren_menu: Control

# mapa de qual nova diagonal ele deve ir dependendo de onde bate
var dir_possibles_crash_wall = {
		Vector2( 1,   1)  : {"right" : Vector2(-1,  1), "down" : Vector2( 1, -1)},
		Vector2( 1,  -1)  : {"right" : Vector2(-1, -1), "up"   : Vector2( 1,  1)},
		Vector2(-1,   1)  : {"left"  : Vector2( 1,  1), "down" : Vector2(-1, -1)},
		Vector2(-1,  -1)  : {"left"  : Vector2( 1, -1), "up"   : Vector2(-1,  1)}
	}
	
var layers = {
	"player" : 1 << 0,
	"enemy" : 1 << 1,
	"boss": 1 << 2,
	"wall_boss": 1 << 3,
	"wall_current_room": 1 << 4,
	"out_room_boss": 1 << 5,
	"ghost": 1 << 6,
	"no_collision_wall": 1 << 7
}

#var drops = {
	#"comum": {"chance" : 0.5, "item": [
		#"heart",
		#"coin"
	#]},
	#"rare": {"chance": 0.7, "item": [
		#"power"
	#]}
#}

var drops = {
	"comum": {"chance" : 0.0, "item": [
		"coin"
	]}
}
	
var ene_in_crash_attack: Array[Enemy]
var special_ghost_collision = 2

var already_center = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	
	if player == null: return
	player_pos = player.body.global_position

	if die:
		if Input.is_key_label_pressed(KEY_SPACE):
			get_tree().reload_current_scene()
			get_tree().paused = false
			die = false
		
	if is_get_animation:
		if Input.is_anything_pressed():
			finish_get_animation()
		
func desable_room():
	current_room.desable()
	
func enable_room():
	current_room.enable()
	
func set_teleport(can: bool):
	if can:
		get_tree().create_timer(0.5).timeout
		Globals.can_teleport = true
	else:
		Globals.can_teleport = false

func is_clean_room():
	return current_room.is_clean()
	
func drop_key():
		
	if true: return
		
	if current_room.already_drop_key: return
	
	var is_for_drop = false
	
	if current_room.calculate_total_enemies() == 1:
		is_for_drop = true
	elif randf() >= 0.5:
		is_for_drop = true

	if is_for_drop: 
		current_room.already_drop_key = true
		var new_key = generate_random_key()
		return new_key
		
	return null

func generate_random_key():
	
	var possibles_keys = []
	
	for door in current_room.doors:
		if door is Door:
			if door.name != "ParentsRoom" and door.is_locked:
				possibles_keys.append(current_room.name + "," + door.name)
			
	var key: Key = null
	
	if not possibles_keys.is_empty():
		key = Key.generate_key(possibles_keys.pick_random())

	return key
		
func finish_get_animation():
	
	get_tree().paused = false
	
	player.anim.process_mode = Node.PROCESS_MODE_INHERIT
	for key in current_room.get_children():
		if key is Key:
			key.queue_free()
	update_room_light()
	is_get_animation = false
	
func update_room_light():
	current_room._update_doors_light()
	
#func change_room():
	#current_room._update_doors_light()
	#current_room.update_layers()
	#if current_room.finish: return

func time(time: float):
	return get_tree().create_timer(time).timeout
	
func _on_goint_to_center():
	already_center += 1
	if already_center >= 8:
		emerge_boss.emit()
		already_center = 0

func get_special_time_ghost_run():
	special_time_ghost_run += 0.5
	return special_time_ghost_run

func dir_to(current: Vector2, target: Vector2):
	return current.direction_to(target)
	
func create_curve(p0: Vector2, p1: Vector2, p2: Vector2, t: float = 0.001) -> Array[Vector2]:
		
	var curve: Array[Vector2] = []
	var time: float = 0

	while time < 1:
		var q1 = p0.lerp(p1, time)
		var q2 = p1.lerp(p2, time)
		var r = q1.lerp(q2, time)
		curve.append(r)
		time += t 

	return curve
	
func create_curve_drop(start: Vector2, right: bool = true, x_scala: float = 1.5, y_scala: float = 4.5, angle: float = 0, t: float = 0.001) -> Array[Vector2]:
	var p0: Vector2 = start
	var p1: Vector2 = start
	var p2: Vector2 = start
	
	p2.x *= x_scala
	
	p2.y += 30 * y_scala

	if not right:
		p2.x = p0.x - (p2.x - p0.x)
	
	p1.x = p0.lerp(p2, 0.5).x
	p1.y -= 100 * y_scala
	
	if not right:
		p1.x = p0.x - (p0.x - p1.x) 

	var curve := create_curve(p0, p1, p2, t)
		
	var center = curve[0]
		
	for i in curve.size() - 1:
		curve[i] = (curve[i] - center).rotated(angle) + center
		
	return curve
	
func try_drop(pos: Vector2):
	var p = randf()

	var item: String = ""

	for i in drops.keys():
		if p > drops[i]["chance"]:
			item = drops[i]["item"].pick_random()
			
	if not item.is_empty():
		drop(item, pos)
		
func drop(item: String, pos: Vector2):
	var i = Item.create_item(item, pos)
	add_child(i)
	
#Usando no room_manager, para quando gerado uma chave, ele desbloquei as portas
#Esse sinal é emitido pelo player, para emitir so quando a animação de pegar a
#chave for finalizada 
signal generate_new_key(key: Key)

signal goint_to_center

signal emerge_boss

signal gone_use_array
