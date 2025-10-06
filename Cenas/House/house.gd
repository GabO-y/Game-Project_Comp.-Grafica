extends Node2D

@onready var player := $Player
@onready var enemies: Array[Enemy]

@onready var room_manager := $RoomManager
@onready var transaction_scene := $TransitionScene

func _ready() -> void:
			
	Globals.player = player
	Globals.set_initial_room("MegaGhostRoom")
			
	Globals.enable_room()

	room_manager.match_doors("SafeRoom","HallWay1")
	room_manager.match_doors("Hallway1", "MiniRoom")
	
	player.player_die.connect(transaction_scene._finish_round)
	
func _process(delta: float) -> void:

	#print(Globals.current_room.is_clean())
		
	pass

		

		
