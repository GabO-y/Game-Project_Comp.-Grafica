extends Room

@export var down_coll: Area2D
@export var up_coll: Area2D
@export var left_coll: Area2D
@export var right_coll: Area2D
@export var inside_area: Area2D
@export var segs_node: Node2D
@export var boss: MegaGhost

var is_attack_running_fantasm = false

var segs: Array[Line]
var fantasm_on_attack = []
var is_last_update_bar = false
var time_can_go = 3

func _ready():
		
	setup()
	
	out_of_camera.connect(start_special_attack)
	start_attacks_fanstams_running.connect(running_fantasms)
	finish_running_fantasm.connect(start_entrace_boss)
	
func _physics_process(delta: float) -> void:

	for attr in fantasm_on_attack:
		var fan = attr["fan"] as Enemy
		var dir = attr["dir"] as Vector2
				
		if attr.has("is_continue_toward") and attr["is_continue_toward"]:
			dir = attr["last_dir"]
		else:
			if fan.body.global_position.distance_to(Globals.player.player_body.global_position) < 40:
				attr["dir"] = attr["last_dir"]
				
				if attr["dir"] or attr["dir"] == Vector2.ZERO:
					attr["dir"] = fan.body.global_position.direction_to(Globals.player.player_body.global_position)
					
				attr["is_continue_toward"] = true
			else:
				attr["dir"] = fan.body.global_position.direction_to(Globals.player.player_body.global_position)
				attr["last_dir"] = attr["dir"]
		
		fan.body.velocity = fan.speed * dir
		fan.body.move_and_slide()

func _process(delta: float) -> void:
	if is_last_update_bar:
		$DamageBar.value -= 0.4
		if $DamageBar.value <= 0:
			is_last_update_bar = false

func _on_left_coll_body_entered(area_body: Node2D) -> void:	
	out_of_camera.emit(area_body.get_parent())
	
func _on_up_coll_body_entered(area_body: Node2D) -> void:
	out_of_camera.emit(area_body.get_parent())

func _on_down_coll_body_entered(area_body: Node2D) -> void:
	out_of_camera.emit(area_body.get_parent())

func _on_right_coll_body_entered(area_body: Node2D) -> void:
	out_of_camera.emit(area_body.get_parent())

func get_randm_point_segment(line: Line, top_down: bool):
	
	var x1 = line.x1
	var y1 = line.y1
	
	var x2 = line.x2
	var y2 = line.y2
	
	var m = (y2 - y1) / (x2 - x1)
	
	var limit = line.get_limit()
	
	var x: float
	var y: float
	
	if top_down:
		x = limit["min"] + int(randf() * (limit["max"] * 2))
		y = (m * (x - 1)) + y1
	else:
		y = limit["min"] + int(randf() * (limit["max"] * 2))
		x = x1 + (y - y1)/m
			
	return Vector2(x, y)

func start_special_attack(thing):
	#if thing.get_parent() != boss: return
	start_running_fantasm(thing)

func start_running_fantasm(thing):
	
	if thing is Fantasm:
		for i in fantasm_on_attack:
			if i["fan"] == thing:
				fantasm_on_attack.erase(i)
				break
				
		thing.die()
		return
		
	if is_attack_running_fantasm: return
	is_attack_running_fantasm = true
		
	boss.is_stop = true	

	var fantasm = load("res://Cenas/Enemie/Fantasm/Fantasm.tscn").instantiate() as Fantasm

	for i in range(10):
		
		fantasm = load("res://Cenas/Enemie/Fantasm/Fantasm.tscn").instantiate() as Fantasm
		var seg = segs.pick_random()
		call_deferred("add_child", fantasm)
						
		fantasm.name = seg.name + str(randf())
				
		var point = get_randm_point_segment(
				seg,
				fantasm.name.contains("up") or fantasm.name.contains("down")
			)

		fantasm.global_position = point
		
		fantasm.tree_entered.connect(
			func():
				fantasm.body.collision_mask = Globals.collision_map["special_attack_area_megaghost"]
				fantasm.body.collision_layer = Globals.collision_map["special_attack_area_megaghost"]
				fantasm.is_running_attack = true
				
				fantasm.add_to_group("attack_queue")
				start_attacks_fanstams_running.emit(fantasm)
				fantasm.enemy_die.connect(check_end_running_fantasm)
				fantasm.speed = 200
		)
	
func running_fantasms(fan: Enemy):
	
	fan.body.collision_layer = Globals.collision_map["special_attack_area_megaghost"]
	
	var dir: Vector2 = fan.body.global_position.direction_to(Globals.player.player_body.global_position)
		
	time_can_go *= 1.1
	await get_tree().create_timer(time_can_go).timeout
	fantasm_on_attack.append({"fan": fan, "dir": dir, "is_continue_toward": false})
	
func start_entrace_boss():
	
	await get_tree().process_frame
	boss.body.collision_layer = inside_area.collision_layer
	boss.body.collision_mask = inside_area.collision_mask
	
	var ran_dir = segs.pick_random().name
	ran_dir = "right"
	
	var x: float
	var y: float
		
	for line in segs:
		if line.name == ran_dir:
			match ran_dir:
				"up": y = line.y2 + 100
				"down": y = line.y2
				"right": x = line.x1 
				"left": x = line.x1 
			break
			
	match ran_dir:
		"down", "up": x = Globals.player.player_body.global_position.x
		"left", "right": y =  Globals.player.player_body.global_position.y
		
	var limit
	for i in segs:
		if i.name == ran_dir:
			limit = i.get_limit()
				
	var max_limit = limit["max"] - (limit["max"] * 0.1)
	var min_limit = limit["min"] - (limit["min"] * 0.1)
		
	match ran_dir:
		"up", "down":
			if x >= max_limit or x <= min_limit:
				x *= 0.9
		"right", "left":
			if y >= max_limit or  y <= min_limit:
				y *= 0.8	
				
	boss.body.global_position = Vector2(x, y)
	
	var dir: Vector2
	
	match ran_dir:
		"up": dir = Vector2.DOWN
		"down": dir = Vector2.UP
		"left": dir = Vector2.RIGHT
		"right": dir = Vector2.LEFT
					
	await get_tree().create_timer(1).timeout
	fantasm_on_attack.append({"fan": boss, "dir": dir})
	
func check_end_running_fantasm(ene):
	if fantasm_on_attack.is_empty():
		finish_running_fantasm.emit()
		
func _on_inside_area_body_entered(body: Node2D) -> void:
	refrash_setup()
	boss.refrash_setup()
	
func refrash_setup():
	is_attack_running_fantasm = false
	time_can_go = 3
	fantasm_on_attack.clear()
	
func setup():

	segs.clear()
	
	for seg in segs_node.get_children():
		
		seg = seg as Line2D
					
		var x1 = seg.points[0][0]
		var y1 = seg.points[0][1]
		var x2 = seg.points[1][0]
		var y2 = seg.points[1][1]
				
		var seg_name = seg.name.replace("Line", "")
		segs.append(Line.create_line(seg_name, x1,y1,x2,y2))
			
func _last_update_damage_bar(ene: Enemy) -> void:
	$DamageBar/LifeBar.value = 0
	await get_tree().create_timer(2).timeout
	is_last_update_bar = true
	
signal out_of_camera

signal start_attacks_fanstams_running	

signal finish_running_fantasm

signal check_can_run_ghost(ene: Enemy)

class Line:
	var x1: float
	var y1: float
	var x2: float
	var y2: float
	var name: String
	
	static func create_line(line_name, x1, y1, x2, y2) -> Line:
		
		var line = Line.new()
		line.name = line_name.to_lower()
		line.x1 = x1
		line.y1 = y1
		line.x2 = x2
		line.y2 = y2
		return line
		
	func get_limit():
		if name.contains("left") or name.contains("right"):
			return {"max": max(y1, y2), "min": min(y1, y2)}
		if name.contains("up") or name.contains("down"):
			return {"max": max(x1, x2), "min": min(x1, x2)}
	
	func _to_string() -> String:
		return str(self.name, "\n\tp1: (", x1, ", ", y1, ")\n\tp2: (", x2, ", ", y2, ")\n")
