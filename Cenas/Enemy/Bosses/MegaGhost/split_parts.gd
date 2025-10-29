extends Enemy

class_name Split

var dir_special_attack: Vector2
var last_wall_collide: String
var times_crash_wall = 0
var already_split = false
var speed_special_attack = 300
var times_to_split = 4
var ene_in_crash_attack: Array[Enemy]

@export var random_dir_timer: Timer
@export var node_rays: Node2D
@export var vertical_point_1: Marker2D
@export var vertical_point_2: Marker2D
@export var horizontal_point_1: Marker2D
@export var horizontal_point_2: Marker2D
@export var local_var: LocalVar


func _ready() -> void:
	is_running_attack = true
	
func _entered_hit_area(body: Node2D) -> void:
	var pla = body.get_parent() as Player
	if pla == null: return
	pla.take_damage(damage)
	
func move_crash_wall():
		
	var collision = body.move_and_collide(dir_special_attack * speed_special_attack)
	
	if collision:
						
		var collider = collision.get_collider()		
		
		if collider.name == "HalfBodyPart":
			random_dir_timer.stop()
			random_dir_timer.start()
		
		dir_special_attack = Globals.dir_possibles_crash_wall[dir_special_attack].get(last_wall_collide,
			get_random_dir()
		)
			
		if times_crash_wall != 0 and times_crash_wall % times_to_split == 0 and not already_split:
			split_when_crash()
			already_split = true
		else:
			times_crash_wall += 1
			
	
func move_all_crash_wall():
	for ene in ene_in_crash_attack:
		ene.move_crash_wall()

func split_when_crash():
	pass

func set_collision_layer_ray(layer: int):
	for i in node_rays.rays:
		(i as RayCast2D).set_collision_mask_value(layer, true)

func _on_ray_to_wall_crash_wall(name: String) -> void:
	last_wall_collide = name

func get_random_dir():
	return Vector2(
		[-1, 1].pick_random(),
		[-1, 1].pick_random()
	)

func _on_timer_timeout() -> void:
	random_dir_timer.wait_time = 1 + randf() * 4
	dir_special_attack = get_random_dir()
