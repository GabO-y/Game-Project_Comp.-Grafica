extends Node2D

class_name Room

@export var is_clear: bool = false
@export var finish = false
@export var spaweners: Array[Spawn]
@export var spread: bool = false
var spread_one = false
var doors: Array[Door]
var total_enemies: int = 0
var already_drop_key = false

func _ready() -> void:
	for child in get_children():
		if child is Spawn:
			spaweners.append(child)
		if child is Door:
			doors.append(child)
			
	first_clear.connect(_items_go_player)
			
			
func _process(delta: float) -> void:
	if !finish:
		if is_clean():
			finish = true
			first_clear.emit()
			print("emitido")
		
func calculate_total_enemies() -> int:	
	total_enemies = 0

	for spa in spaweners:
		total_enemies += spa.enemies.size()
		
	return total_enemies

func is_clean() -> bool:
	for spawn in spaweners:
		if spawn is Spawn:			
			if !spawn.is_clean(): return false
			
	return true
	
func desable():
	switch_process(false)
			
func enable():
	switch_process(true)
			
func switch_process(mode: bool):
	
	if mode: show()
	else: hide()
	
	spread = mode
	
	for item in get_children():
		if item is Door:
			item.area.set_deferred("monitoring", mode)
		if item is TileMapLayer:
			item.collision_enabled = mode
		if item is Spawn:
			item.switch(mode)
			
func _items_go_player():
	for item in get_children():
		if item is Item:
			item.is_to_chase_player = true
				
signal first_clear
