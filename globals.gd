extends Node

var current_room: Room
var last_scene
var can_teleport = true
var player: Player
var die = false
var already_keys = []
var is_get_animation = false
var center_pos: Vector2

var is_using_array = false

# mapa de qual nova diagonal ele deve ir dependendo de onde bate
var dir_possibles_crash_wall = {
		Vector2( 1,   1)  : {"right" : Vector2(-1,  1), "down" : Vector2( 1, -1)},
		Vector2( 1,  -1)  : {"right" : Vector2(-1, -1), "up"   : Vector2( 1,  1)},
		Vector2(-1,   1)  : {"left"  : Vector2( 1,  1), "down" : Vector2(-1, -1)},
		Vector2(-1,  -1)  : {"left"  : Vector2( 1, -1), "up"   : Vector2(-1,  1)}
	}
	
var ene_in_crash_attack: Array[Enemy]
var special_ghost_collision = 2

var already_center = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	
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
	
func change_room():
	current_room._update_doors_light()
	if current_room.finish: return

func set_initial_room(name: String):
	for room in get_tree().get_nodes_in_group("rooms"):
		if room.name == name:
			current_room = room
			break

func time(time: float):
	return get_tree().create_timer(time).timeout
	
	
func _on_goint_to_center():
	already_center += 1
	print(already_center)
	if already_center >= 8:
		emerge_boss.emit()
		already_center = 0
	
func connect_safe(sign, function):
	sign.connect(function)
	
	if sign and (sign as Signal).is_connected(function):
		print(sign, " connect")
	else:
		print(sign, " not connect")
	
	
#Usando no room_manager, para quando gerado uma chave, ele desbloquei as portas
#Esse sinal é emitido pelo player, para emitir so quando a animação de pegar a
#chave for finalizada 
signal generate_new_key(key: Key)

signal goint_to_center

signal emerge_boss

signal gone_use_array
