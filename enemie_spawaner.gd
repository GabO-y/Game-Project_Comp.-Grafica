extends Node2D

class_name Spawn

@export var type_enemie: PackedScene
@export var limit_spawn = 5
@export var time_to_spawn = 3.0

var enemies_already_spawner = 0
var enemies: Array[Enemie] = []
var time = 0
	
func _process(delta: float) -> void:
		
	time += delta
	
	for i in enemies:
		if !i.is_processing():
			enemies.erase(i)
			remove_child(i)
	
	if(time >= time_to_spawn && enemies_already_spawner < limit_spawn):
		time = 0
		var enemie = spawanEmenie()
		enemies_already_spawner += 1

func get_random_point_in_area(area: Area2D) -> Vector2:
	# 1. Pega o CollisionShape2D da área
	var collision_shape = area.get_node("CollisionShape2D") as CollisionShape2D
	
	# 2. Verifica se existe e tem um shape
	if not collision_shape or not collision_shape.shape:
		push_error("Area2D não tem CollisionShape2D ou shape definido!")
		return area.global_position
	
	# 3. Converte para CircleShape2D
	if collision_shape.shape is CircleShape2D:
		var circle = collision_shape.shape as CircleShape2D
		var radius = circle.radius
		
		# Gera um ponto aleatório dentro do círculo (distribuição uniforme)
		var angle = randf_range(0, TAU)
		var distance = sqrt(randf()) * radius
		
		# Calcula o ponto em coordenadas locais do CollisionShape2D
		var local_point = Vector2(cos(angle), sin(angle)) * distance
		
		# Converte para coordenadas globais CORRETAMENTE
		return collision_shape.to_global(local_point)
	else:
		push_error("O shape não é um CircleShape2D!")
		return area.global_position

func spawanEmenie() -> Enemie:
	
	if type_enemie == null:
		return
	
	var point = get_random_point_in_area($Area2D)
	
	var ene = type_enemie.instantiate()
	ene.global_position = point
	
	add_child(ene)
	enemies.append(ene)
	
	return ene
	
func set_enemie(ene: PackedScene):
	type_enemie = ene
	
