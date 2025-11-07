extends Node2D

class_name KeyManager

@export var room_manager: RoomManager

# A cada troca de sala, ele verifica se há portas que podem ser abertas,
# caso haja, ele guarda nessa variavel
var current_door_can_open: Array[Door]

# Quando uma chave é criada, ela não é automaticamente lançada,
# quem lida com isso, é o item_manager, ent, essa variavel 
# vai guardar se tem uma chave pro item manager criar
var has_key: bool = false
var key: Key
	
func find_doors(room: Room):
	
	var doors: Array[Door]
	
	for door in room.doors:
		
		if door.goTo is BossRoom:
			if door.goTo.finish:
				continue
		
		if door.is_locked:
			doors.append(door)
	
#	Sorteia a porta que vai abrir
	var drawn_door = doors.pick_random() as Door
	
	if !drawn_door: return
	
#	Pega o quarto que a porta leva
	var room_target = drawn_door.goTo as Room
#	Variavel que vai pegar a porta correspondente ao quarto atual
	var door_target: Door
			
#   Com o quarto que a nossa porta sortada abre,
#   procuramos a porta correspondente
	for door in room_target.doors:
		if door.name == room_manager.current_room.name:
			door_target = door
			break
			
	if !door_target:
		return null
		
	return {
		"door_current": drawn_door,
		"door_target": door_target
	}
		
func create_key(room: Room) -> Key:
		
	var doors = find_doors(room)
		
	if !doors: return null
	
	var key: Key = load("res://Cenas/Keys/Key.tscn").instantiate() 

	key.door1 = doors["door_current"]
	key.door2 = doors["door_target"]
	
	return key
	

	
	
			
	
		
