extends Node2D

@onready var player := $Player
@onready var enemies: Array[Enemy]

@onready var transaction_scene := $TransitionScene

@export var room_manager: RoomManager

func _ready() -> void:
	
	room_manager.set_initial_room("SafeRoom")
	
	Globals.player = player
	
	
func _physics_process(delta: float) -> void:
	pass	
	#for room in room_manager.rooms:
		#room = room as Room
		#if room.name == "BossGhostRoom":
			#for la in room.layers:
				#la = la as TileMapLayer
				#print(la.tile_set.get_physics_layer_collision_mask(0))
