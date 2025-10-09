extends Enemy

class_name Part

@export var rays: Array[RayCast2D]
@export var ghost: Enemy
@export var random_dir_timer: Timer
@export var vertical_point: Marker2D
@export var horizontal_point: Marker2D
@export var center_pos = Vector2(0, 0)

var locals: LocalVar
var test = false
var ene_in_crash_attack: Array[Enemy]
var last_wall_collide: String
var times_crash = 0
var is_splited = false
var is_stop = false
var is_min_min = false
var toward_center = false
var dir_special_attack: Vector2
var speed_special_attack: int

func _ready() -> void:

	body = ghost.body

	end_split_attack.connect(_end_split_attack)
	random_dir_timer.timeout.connect(_random_dir)

func _process(delta: float) -> void:
	
	
	if is_stop: return

	for ray in rays:
		ray.global_position = body.global_position
		
	move_crash_wall()

func move_crash_wall():
	
	if is_stop: return
		
	for ray in rays:
		if ray.is_colliding():
			last_wall_collide = ray.name.to_lower()
	
	var collision = body.move_and_collide(dir_special_attack * speed_special_attack)
		
	if collision: 
				
		var collider = collision.get_collider()
		dir_special_attack = Globals.dir_possibles_crash_wall[dir_special_attack].get(last_wall_collide, -dir_special_attack)
		dir = dir_special_attack
		
		if times_crash == 4 and not is_min_min:
			
			if is_min_min: return
			
			split()
			
			is_splited = true
			
		else:
			times_crash += 1
		
func set_collision_layer_ray(layer: int):
	for ray in rays:
		ray.set_collision_mask_value(layer, true)

func get_random_dir() -> Vector2:
	return Vector2(
		[1, -1].pick_random(),
		[1, -1].pick_random()
	)

func _random_dir() -> void:
	
	if toward_center: return
	
	random_dir_timer.wait_time = 1 + (2 * randf())
	dir_special_attack = get_random_dir() # Replace with function body.

func split():

	if is_min_min: return

	body.hide()
	ene_in_crash_attack.erase(self)
	
	var first_part = load("res://Cenas/Enemie/Bosses/MegaGhost/Parts/MinPart/MinPart.tscn").instantiate() as MinPart
	var second_part = load("res://Cenas/Enemie/Bosses/MegaGhost/Parts/MinPart/MinPart.tscn").instantiate() as MinPart
	
	add_child(first_part)
	add_child(second_part)
	
	first_part.locals = locals
	second_part.locals = locals
	
	
	ene_in_crash_attack.append(first_part)
	ene_in_crash_attack.append(second_part)
	
	for ene in ene_in_crash_attack:
		
		ene = ene as MinPart
		
		if ene == null or is_min_min: continue
		
		ene.ene_in_crash_attack = ene_in_crash_attack
		
		ene.dir_special_attack = dir_special_attack
		ene.speed_special_attack = speed_special_attack
		ene.last_wall_collide = last_wall_collide
		
		ene.body.collision_layer = 1 << 2
		ene.body.collision_mask = 1 << 2
		
		ene.set_collision_layer_ray(3)
		
	second_part.dir_special_attack = -dir_special_attack
	
	match last_wall_collide:
		"up", "down":
			horizontal_point.global_position = body.global_position
			first_part.body.global_position = horizontal_point.global_position
			second_part.body.global_position = horizontal_point.global_position
			second_part.body.global_position.x *= 1.1
		"left", "right":
			vertical_point.global_position = body.global_position
			first_part.body.global_position = vertical_point.global_position
			second_part.body.global_position = vertical_point.global_position 
			second_part.body.global_position.y *= 1.1
		
	body.collision_layer = 0
	body.collision_mask = 0
	
	set_collision_layer_ray(0)
	
	is_active = false
	is_stop = true
	
	return [first_part, second_part]

func _end_split_attack() -> void:
		
	body.collision_layer = 0
	body.collision_mask = 0

	toward_center = true
	test = true
	
	print(toward_center)
	
signal end_split_attack

signal all_in_center

	
	
