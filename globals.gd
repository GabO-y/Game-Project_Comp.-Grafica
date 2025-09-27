extends Node

var current_scene: Room
var last_scene
var can_teleport = true
var player: Player
var die = false
var already_keys = []


func _process(delta: float) -> void:
	
	if Input.is_key_pressed(KEY_SPACE) and die:
		die = false
		get_tree().paused = false
		get_tree().reload_current_scene()
		
	process_mode = Node.PROCESS_MODE_ALWAYS
		
func desable_room():
	current_scene.desable()
	
func enable_room():
	current_scene.enable()
	
func set_teleport(can: bool):
	if can:
		get_tree().create_timer(0.5).timeout
		Globals.can_teleport = true
	else:
		Globals.can_teleport = false


func is_clean_room():
	return current_scene.is_clean()
	
func add_probably_key(r1: String, r2: String):
	
	for keys in already_keys:
		
		var k = keys[0].split(",")
		
		if str(k[0]) == r1 and str(k[1]) == r2:
			#print("negada chave: ", str(k[0], ",", k[1]))
			return
		elif str(k[0]) == r2 and str(k[1]) == r1:
			#print("negada chave: ", str(k[1], ",", k[0]))
			return
	
	#print("aceita chave: ", str(r1, ",", r2))
	
	var new_key = Key.generate_key(r1 + "," + r2)
	
	already_keys.append([new_key, true])
		
func random_width(options: Array, widths: Array):
	var total_width = 0
	for width in widths:
		total_width += width
	
	var rand = randf() * total_width
	var accumulate = 0
	
	for i in range(options.size()):
		accumulate += widths[i]
		if rand < accumulate:
			return options[i]
	
	return options[0]  # Fallback
	
func available_key(key: Key) -> bool:
	
	for i in already_keys:
		var key_a = i[0] as Key
		
		if key_a.equals(key):
			return false
		
	return true
