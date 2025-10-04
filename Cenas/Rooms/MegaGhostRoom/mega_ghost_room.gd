extends Room

@export var down_coll: Area2D
@export var up_coll: Area2D
@export var left_coll: Area2D
@export var right_coll: Area2D
@export var inside_area: Area2D

@export var boss: MegaGhost
var is_attack_running_fantasm = false

var segs: Array[Line]
var fantasm_on_attack = []
var check_collider = false

func _ready():
	
	segs.append(Line.create_line("up",-60,-70,330,-70))
	segs.append(Line.create_line("down",-60,250,330,250))
	segs.append(Line.create_line("left", -175, 16,-175, 175))
	segs.append(Line.create_line("right", 420,16,420,175))

	out_of_camera.connect(start_special_attack)
	start_attacks_fanstams_running.connect(running_fantasms)
	finish_running_fantasm.connect(start_entrace_boss)
	
func _physics_process(delta: float) -> void:
	
	for attr in fantasm_on_attack:
		var fan = attr["fan"] as Enemy
		var dir = attr["dir"] as Vector2
		fan.body.velocity = fan.speed * dir
		fan.body.move_and_slide()

signal out_of_camera

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
		x = limit[1] + int(randf() * limit[0])
		y = (m * (x - 1)) + y1
	else:
		y = limit[1] + (int(randf() * limit[0]))
		x = x1 + (y - y1)/m
	
		
	return Vector2(x, y)

func start_special_attack(thing):
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
				fantasm.body.collision_mask = 1 << 4
				fantasm.body.collision_layer = 1 << 4
				fantasm.running_attack = true
				
				fantasm.add_to_group("attack_queue")
				start_attacks_fanstams_running.emit(fantasm)
				fantasm.enemy_die.connect(check_end_running_fantasm)
		)
	
func running_fantasms(fan: Enemy):
	
	fan.body.collision_layer = 2
	
	await get_tree().create_timer(3).timeout
	var dir: Vector2
		
	if fan.name.contains("up"):
		dir = Vector2.DOWN
	if fan.name.contains("down"):
		dir = Vector2.UP
	if fan.name.contains("left"):
		dir = Vector2.RIGHT
	if fan.name.contains("right"):
		dir = Vector2.LEFT
					
	fantasm_on_attack.append({"fan": fan, "dir": dir})
		
func start_entrace_boss():
	
	await get_tree().process_frame
	boss.body.collision_layer = inside_area.collision_layer
	boss.body.collision_mask = inside_area.collision_mask
	
	var ran_dir = ["up", "down", "right", "left"].pick_random()
	
	var x: float
	var y: float
		
	for line in segs:
		if line.name == ran_dir:
			match ran_dir:
				"up": y = line.y1
				"down": y = line.y1 + 50
				"right": x = line.x1 + 100
				"left": x = line.x1 
			break
			
	match ran_dir:
		"down", "up": x = Globals.player.player_body.global_position[0]
		"left", "right": y =  Globals.player.player_body.global_position[1]
		
	if y > 190:
		y -= 20
	if y < 60:
		y += 17
	if x < 25:
		x += 20
	if x > 430:
		x -= 20
		
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
	fantasm_on_attack.clear()
	
class Line:
	var x1: float
	var y1: float
	var x2: float
	var y2: float
	var name: String
	
	static func create_line(name, x1, y1, x2, y2) -> Line:
		var line = Line.new()
		line.name = name
		line.x1 = x1
		line.x2 = x2
		line.y1 = y1
		line.y2 = y2
		return line
		
	func get_limit():
		if name.contains("left") or name.contains("right"):
			return [max(y1, y2), min(y1, y2)]
		if name.contains("up") or name.contains("down"):
			return [max(x1, x2), min(x1, x2)]

signal start_attacks_fanstams_running	

signal finish_running_fantasm
