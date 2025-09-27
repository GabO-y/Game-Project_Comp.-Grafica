extends Node2D

class_name Room

@export var is_clear: bool = false
@export var finish = false
@export var spaweners: Array[Spawn]
@export var spread: bool = false
var spread_one = false
var doors: Array[Door]

func _ready() -> void:
	for child in get_children():
		if child is Spawn:
			spaweners.append(child)
		if child is Door:
			doors.append(child)
			
func _process(delta: float) -> void:
	if spread:
		spread_items()
		
func is_clean() -> bool:
	for spawn in spaweners:
		if spawn is Spawn:			
			if !spawn.is_clean(): return false
			
	claer_room.emit()
	
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
				
func spread_items():
	for spa in spaweners:
				
		if spa.enemies_already_spawner == spa.limit_spawn and spread_one:
			return
			
		print("a")
		
		for ene in spa.enemies:
									
			if !spa.someone_cotains_key():
				ene.drop.append(get_random_key())
							
			if ene.drop.size() < ene.max_drop_amount:
				ene.drop.append(get_random_drop())
				
			spread_one = true

signal claer_room

func get_random_key() -> Key:
		
	var possible_keys = []
	
	for i in get_children():
		if i is Door:
			possible_keys.append(str(name, ",", i.name))
			
	var random_key_name = possible_keys.pick_random()
	
	var key = Key.generate_key(random_key_name)

	while Globals.already_keys.find(random_key_name) != -1:
		random_key_name = possible_keys.pick_random()
		
		
	Globals.already_keys.append(random_key_name)
	
	print("chave gerada: ", key)
	
	return key
	
func get_random_drop():
	return Globals.random_width(["A", "B", "C"], [50, 40, 10])
	pass
	
