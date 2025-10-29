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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func check_doors():
	
	var current_room = room_manager.current_room
	
	current_door_can_open.clear()
	
	for door in current_room.doors:
		if door.is_locked:
			current_door_can_open.append(door)
			
			
func find_doors():
	
#	Sorte a porta que vai abrir
	var door_current = current_door_can_open.pick_random() as Door
	
	if !door_current: return
	
#	Pega o quarto que a porta leva
	var room_target = door_current.goTo as Room
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
		"door_current": door_current,
		"door_target": door_target
	}
		
func create_key() -> Key:
	
	var doors = find_doors()
	
	if !doors: return null
	
	var key: Key = load("res://Cenas/Keys/Key.tscn").instantiate() 

		
	key.door1 = doors["door_current"]
	key.door2 = doors["door_target"]
	
	return key
	

	
	
			
	
		
