extends Enemy

var dir_special_attack: Vector2
var last_wall_collide: String
var times_crash_wall = 0
var already_split = false
var speed_special_attack = 300

@export var random_dir_timer: Timer
@export var node_rays: Node2D

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
			
		if times_crash_wall != 0 and times_crash_wall % 2 == 0 and not already_split:
			split_when_crash()
			#already_split = true
			#get_parent().ene_in_crash_attack.erase(self)
		else:
			times_crash_wall += 1
	
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
	random_dir_timer.wait_time = [1, 1.5, 2].pick_random()
	dir_special_attack = get_random_dir()
