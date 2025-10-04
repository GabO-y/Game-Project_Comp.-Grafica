extends Node2D

@onready var player := $Player
@onready var enemies: Array[Enemy]

@onready var room_manager := $RoomManager
@onready var transaction_scene := $TransitionScene

var activateArmor = true
var armor: LightArmor
var infosModeActivate = false
var spawns: Array[Spawn] = []

func _ready() -> void:
			
	Globals.player = player
	Globals.set_initial_room("SafeRoom")
		
	Globals.enable_room()

	room_manager.match_doors("SafeRoom","HallWay1")
	room_manager.match_doors("ParentsRoom","HallWay1")
	room_manager.match_doors("MiniRoom", "HallWay1")
	room_manager.match_doors("SafeRoom", "MegaGhostRoom")
	
	player.player_die.connect(transaction_scene._finish_round)
	
	print(player.player_body.collision_layer)
	print(player.player_body.collision_mask)
	$RoomManager/SafeRoom/Layers
			

		

		
