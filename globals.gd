extends Node

var current_room: Room
var last_scene
var can_teleport = true
var player: Player
var die = false
var already_keys = []
var is_get_animation = false

func _process(delta: float) -> void:
		
	if is_get_animation:
		if Input.is_anything_pressed():
			finish_get_animation()
		
	process_mode = Node.PROCESS_MODE_ALWAYS
		
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
		return generate_random_key()
		
	return null

func generate_random_key():
	
	var possibles_keys = []
	
	for door in current_room.get_children():
		if door is Door:
			if door.name != "ParentsRoom" and door.is_locked:
				possibles_keys.append(current_room.name + "," + door.name)
			
	var key: Key = null
	
	if not possibles_keys.is_empty():
		key = Key.generate_key(possibles_keys.pick_random())

	return key
	
signal generate_new_key(key: Key)
	
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
	
