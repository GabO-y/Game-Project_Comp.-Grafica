extends Node2D

var rooms: Array[Room]
@export var roomsNode: Node2D

func _ready() -> void:		
	
	for room in roomsNode.get_children():
		if room is Room:
			room.add_to_group("rooms")
			room.desable()
			rooms.append(room)
			for door in room.doors:
				door.player_in.connect(_teleport)

	Globals.generate_new_key.connect(_unlock_doors)
	changed_room.connect(Globals.change_room)

func _teleport(player, goTo):
	
	Globals.desable_room()	
	Globals.current_room = goTo[0]
	Globals.enable_room()
	
	player.global_position = goTo[1]
	
	Globals.can_teleport = false
	await get_tree().create_timer(0.2).timeout
	Globals.can_teleport = true
	
	changed_room.emit()

func match_doors(r_current: String, r_target: String):

	var door_current: Door
	var door_target: Door

	r_current = r_current.to_lower()
	r_target = r_target.to_lower()

	var d_current = r_target.to_lower()
	var d_target = r_current.to_lower()
	
	for room in rooms:
		
		var result: Door
		
		if room.name.to_lower() == r_current:
			result = room.get_door(d_current)
			if result != null:
				door_current = result
		if room.name.to_lower() == r_target:
			result = room.get_door(d_target)
			if result != null:
				door_target = result
			
	
	if door_current == null:
		print("porta: ", d_current, " nao encontrado, do quarto: ", r_current)
		return
	if door_target == null:
		print("porta: ", d_target, " nao encontado, do quarto: ", r_target)
		return

	door_current.goTo = [
		door_target.get_parent().get_parent(), #
		door_target.area.global_position # area de teleport
		]
		
	door_target.goTo = [
		door_current.get_parent().get_parent(),
		door_current.area.global_position
		]
	
func is_clean_room() -> bool:
	return Globals.current_room.is_clean()

func _unlock_doors(key: Key):
	
	var door_1: Door
	var door_2: Door
	
	for room in rooms:
		if room.name == key.what_open[0]:
			door_1 = room.get_door(key.what_open[1])
		if room.name == key.what_open[1]:
			door_2 = room.get_door(key.what_open[0])

					
	if door_1 != null and door_2 != null:
		door_1.is_locked = false
		door_2.is_locked = false
	else:
		if door_1 == null:
			print("porta: ", key.what_open[1], " nao encontrada no quarto: ", key.what_open[0])
		if door_2 == null:
			print("porta: ", key.what_open[0], " nao encontrada no quarto: ", key.what_open[1])

signal changed_room
