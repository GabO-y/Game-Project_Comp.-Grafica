extends Node2D

@export var player: Player
@export var room_manager: RoomManager
@export var transiontion_scene: TransitionScene

func _ready() -> void:
	
	room_manager.set_initial_room("SafeRoom")
	
	Globals.player = player
	Globals.room_manager = room_manager
	
	room_manager.changed_room.connect(active_menu)

# Como o canvasLayer tem que tá na cena main, é ele ativa e desativa o chestMenu 
# basedo no sinal que o room_manager tem, vendo se é o saferoom
func active_menu():
	var is_safe_room = room_manager.current_room.name == "SafeRoom"
	$ChestMenuInterativa/ChestMenu.set_process(is_safe_room)
	$ChestMenuInterativa.visible = is_safe_room
	
