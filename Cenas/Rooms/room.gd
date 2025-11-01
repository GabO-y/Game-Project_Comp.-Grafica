extends Node2D

class_name Room

@export var is_clear: bool = false
@export var finish = false
@export var spaweners: Array[Spawn]
@export var spread: bool = false
@export var doors: Array[Door]
@export var camera: Camera2D
@export var layer_node: Node2D
@export var manager: RoomManager

var layers: Array[TileMapLayer]

var spread_one = false
var total_enemies: int = 0
var already_drop_key = false

func _ready() -> void:
	for child in get_children():
		
		if child is Camera2D:
			camera = child
		
		if child.name == "Spawners":
			for spawn in child.get_children():
				spaweners.append(spawn)
				spawn.room = self
			
		if child.name == "Doors":
			for door in child.get_children():
				if door is Door:
					doors.append(door)
					
		if child.name == "Layers":
			for layer in child.get_children():
				if layer is TileMapLayer:
					layers.append(layer)

func calculate_total_enemies() -> int:	
	total_enemies = 0

	for spa in spaweners:
		total_enemies += spa.enemies.size()
		
	return total_enemies
	
func desable():
	switch_process(false)
			
func enable():
	switch_process(true)
	_check_clear()

func switch_process(mode: bool):
	visible = mode
		
	if camera: camera.enabled = mode
	
	spread = mode
	
	set_process(mode)
	set_physics_process(mode)

	for door in doors:
		if door is Door:
			door.set_active(mode)
			
	for spawn in spaweners:
		if spawn is Spawn:
			spawn.set_active(mode)

	for layer in layers:

		layer.collision_enabled = mode
		layer.navigation_enabled = mode
		
		layer.set_process(mode)
		layer.set_physics_process(mode)
		var lar = Globals.layers["wall_current_room"] if mode else 0
				
		layer.tile_set.set_physics_layer_collision_layer(0, lar)
		layer.tile_set.set_physics_layer_collision_mask(0, lar)
		
	if mode:
		_update_doors()
			
func _update_doors():
	for door in doors:
		door.set_active(!door.is_locked and finish)

# Para todos os efeitos que devem acontecer quando um quarto é finalizado
func _clear_effects():
	_update_doors()
	manager.item_manager.make_items_chase_player()

func get_door(door_name: String) -> Door:
	for door in doors:
		if door is Door and door.name.to_lower() == door_name.to_lower():
			return door
	return null

# Como o sinal da morte de um inmigo precisa de um parametro
# Ent fiz esse pra funcionar, mas é o msm que o "_check_clear"
func _check_clear_by_ene_die(ene):
	_check_clear()

func get_is_clear():
	if not is_clear:
		_check_clear()
	return is_clear

func _check_clear():
		
	for spawn in spaweners:
		if not spawn.is_clean(): 
			is_clear = false
			finish = false
			return
		
	is_clear = true
	finish = true
	_clear_effects()
	clear.emit()
	
# fazendo a parte de items, quando sala limpa, item segue player
signal clear
 
