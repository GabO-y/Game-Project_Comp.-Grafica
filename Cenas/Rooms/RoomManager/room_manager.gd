extends Node2D
class_name RoomManager

var rooms: Array[Room]

@export var roomsNode: Node2D
@export var item_manager: ItemManager
@export var key_manager: KeyManager

var current_room: Room

func _ready() -> void:		
		
	for room in roomsNode.get_children():
				
		if room is Room:
			
			room.add_to_group("rooms")
			room.desable()
			rooms.append(room)
			
			room.manager = self
			
			for door in room.doors:
				door = door as Door
				door.enter_door.connect(_change_room)
		
	for room in rooms:
		for door in room.doors:
			match_doors(room.name, door.name)
			
	
func get_doors(room: Room) -> Array[Door]:
	var doors: Array[Door]
	for door in room.doors:
		doors.append(door)
	return doors
	
func _change_room(goTo):
		
#	Para o caso do player mudar de sala, 
#   mas ainda haver items que não foram coletados
	item_manager.get_all_items()
	
	# Caso vc passe pela porta e não tenha tocado na chave
	
	item_manager.finish_get_key()
	
	current_room.desable()

	var room_name = current_room.name
	
	current_room = goTo
	current_room.enable()
	
	current_room.clear.connect(item_manager.create_key_auto)
	current_room._check_clear()
	
	var door_target = current_room.get_door(room_name)

	Globals.player.body.global_position = door_target.area.global_position
	
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
	
	var find_r1 = false
	var find_r2 = false
	
	for room in rooms:
		
		var result: Door
		
		if room.name.to_lower() == r_current:
			find_r1 = true
			result = room.get_door(d_current)
			if result != null:
				door_current = result
				
		if room.name.to_lower() == r_target:
			find_r2 = true
			result = room.get_door(d_target)
			if result != null:
				door_target = result
			
	if not find_r1:
		print("room: ", r_current, ", nao encontrado")
		return
	if not find_r2:
		print("room: ", r_target, ", nao encontrado")
		return
	
	if door_current == null:
		print("porta: ", d_current, " nao encontrado, do quarto: ", r_current)
		return
	if door_target == null:
		print("porta: ", d_target, " nao encontado, do quarto: ", r_target)
		return
		
	door_current.goTo = door_target.get_parent().get_parent()
	door_target.goTo = door_current.get_parent().get_parent()
		
func enable_room(room_name: String):
	set_mode_room(room_name, true)
	
func desable_room(room_name: String):
	set_mode_room(room_name, false)

func set_mode_room(room_name: String, mode: bool):
	for room in rooms:
		if room.name == room_name:
			if mode:
				room.enable()
			else:
				room.desable()
			return
			
	print("room: ", room_name, " not found")
	return

func set_initial_room(room_name: String):
	if current_room:
		current_room.desable()
		
	for room in rooms:
		if room.name == room_name:
			current_room = room
			current_room.enable()
			return
			
	print("room: ", room_name, " not found")

func is_clean_room() -> bool:
	return current_room.get_is_clear()

# Aqui é pra ficar a logica para ele retornar um quarto que haja portas 
# para serem abertas
func get_room_logic() -> Room:
	return current_room

signal changed_room
