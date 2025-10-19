extends Node2D

class_name Room

@export var is_clear: bool = false
@export var finish = false
@export var spaweners: Array[Spawn]
@export var spread: bool = false
@export var doors: Array[Door]
@export var camera: Camera2D

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
			
		if child.name == "Doors":
			for door in child.get_children():
				if door is Door:
					doors.append(door)
			
	clear.connect(_clear_effects)
					
func _process(delta: float) -> void:
	if !finish:
		is_clean()
		
func calculate_total_enemies() -> int:	
	total_enemies = 0

	for spa in spaweners:
		total_enemies += spa.enemies.size()
		
	return total_enemies

func is_clean() -> bool:
	
	if finish: return true
	
	for spawn in spaweners:
		if spawn is Spawn:			
			if !spawn.is_clean(): return false
			
	finish = true
	clear.emit()
	return true

func _check_clear_by_signal(ene):
	return is_clean()
	
func desable():
	switch_process(false)
			
func enable():
	switch_process(true)
			
func switch_process(mode: bool):
	
	if mode: show()
	else: hide()
	
	camera.enabled = mode
	spread = mode
	
	set_process(mode)
	set_physics_process(mode)
	
	for door in doors:
		if door is Door:
			door.set_process(mode)
			door.area.set_deferred("monitoring", mode)
			
	for spawn in spaweners:
		if spawn is Spawn:
			spawn.switch(mode)
	
	for layers in get_children():
		if layers is TileMapLayer:
			layers.collision_enabled = mode
		if layers.name == "Layers":
			for layer in layers.get_children():
				layer = layer as TileMapLayer
				layer.collision_enabled = mode
				layer.navigation_enabled = mode
				layer.set_process(mode)
				layer.set_physics_process(mode)
						
func _items_go_player():
	for item in get_children():
		if item is Item:
			item.is_to_chase_player = true
			
func _update_doors_light():
	for door in doors:
		door.turn_light(!door.is_locked and finish)
		
func _clear_effects():
	_items_go_player()
	_update_doors_light()

func get_door(door_name: String) -> Door:
	for door in doors:
		if door is Door and door.name.to_lower() == door_name.to_lower():
			return door
	return null
	
func setup():
	pass
	
signal clear
