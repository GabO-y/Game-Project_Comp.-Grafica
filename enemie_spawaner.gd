extends Node2D

class_name Spawn

var type_enemie: PackedScene
var limit_spawn = 5
@export var enemies: Array[Enemie] = []
var time = 0
var time_to_spawn = 3.0
	
func _process(delta: float) -> void:
		
	time += delta
	
	#Caso seja necessario que o spawan continue fazendo nascer bixos caso ele mate eles
	#for i in enemies:
		#if !i.is_processing():
			#enemies.erase(i)
	
	if(time >= time_to_spawn && enemies.size() < limit_spawn):
		time = 0
		var enemie = spawanEmenie()


		
func get_random_point_in_area(area: Area2D) -> Vector2:
	var shape = area.get_node("CollisionShape2D").shape as CircleShape2D
	var radius = shape.radius
	var angle = randf_range(0, TAU)
	var distance = randf_range(0, radius)
	return area.global_position + Vector2(cos(angle), sin(angle)) * distance
	
func spawanEmenie() -> Enemie:
	var point = get_random_point_in_area(get_node("Area2D"))
	
	var ene = type_enemie.instantiate()
	ene.global_position = point
	
	add_child(ene)
	enemies.append(ene)
	
	return ene
	
func set_enemie(ene: PackedScene):
	type_enemie = ene
	
