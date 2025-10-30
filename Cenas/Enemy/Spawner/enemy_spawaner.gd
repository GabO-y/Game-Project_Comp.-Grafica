extends Node2D

class_name Spawn

@export var type_enemie: PackedScene
@export var limit_spawn = 5
@export var time_to_spawn = 3.0
@export var enimies_level = 1

var room: Room
var is_active = false
var enemies_already_spawner = 0
var enemies: Array[Enemy] = []
var time = 0
	
func _process(delta: float) -> void:
	
	time += delta
			
	#for ene in enemies:	
		#if not is_instance_valid(ene): continue
		#
		#if ene.life <= 0:
			#enemies.erase(ene)

#	TODO: por um timer
	if(time >= time_to_spawn && enemies_already_spawner < limit_spawn):
		time = 0
		enemies.append(spawanEmenie())
		enemies_already_spawner += 1
		
func get_random_point_in_area(area: Area2D) -> Vector2:
	var collision_shape = area.get_node("CollisionShape2D") as CollisionShape2D
	
	if not collision_shape or not collision_shape.shape:
		push_error("Area2D não tem CollisionShape2D ou shape definido!")
		return area.global_position
	
	if collision_shape.shape is CircleShape2D:
		var circle = collision_shape.shape as CircleShape2D
		var radius = circle.radius
		
		var angle = randf_range(0, TAU)
		var distance = sqrt(randf()) * radius
		
		# Calcula o ponto em coordenadas locais do CollisionShape2D
		var local_point = Vector2(cos(angle), sin(angle)) * distance
		
		# Converte para coordenadas globais CORRETAMENTE
		return collision_shape.to_global(local_point)
	else:
		push_error("O shape não é um CircleShape2D!")
		return area.global_position

func spawanEmenie() -> Enemy:
	
	if type_enemie == null:
		push_error("ENEMY TYPE IS NULL: ", get_path())
		get_tree().quit()
		return
	
	var point = get_random_point_in_area($Area2D)
	
	point = $Area2D.to_local(point)/2
		
	var ene = type_enemie.instantiate() as Enemy
	
	ene.global_position = point
	ene.position_target = point
	
	ene.enemy_die.connect(_free_enemy)
	ene.enemy_die.connect(room._check_clear_by_ene_die)
	ene.enemy_die.connect(room.manager.item_manager.try_drop)
	
	add_child(ene)
		
	print(is_active)
	ene.set_active(is_active)

	return ene
	
func set_enemie(ene: PackedScene):
	type_enemie = ene
	
func enable():
	set_active(true)

func disable():
	set_active(false)
	
func set_active(mode: bool):
	
	for enemy in enemies:
		enemy.set_active(mode)
		
	set_process(mode)
	visible = mode
	
	is_active = mode
				
func is_clean() -> bool:
	if enemies.size() > 0: return false
	if enemies_already_spawner < limit_spawn: return false
	return true
				
func _free_enemy(ene: Enemy):
	enemies.erase(ene)
	ene.is_active = false
	ene.queue_free()

				
	
			
	
	
	
		
		
	
