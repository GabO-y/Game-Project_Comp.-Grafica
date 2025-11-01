extends Node2D

class_name House

@export var player: Player
@export var room_manager: RoomManager
@export var transiontion_scene: TransitionScene
@export var camera: Camera2D
var follow: Node2D

func _ready() -> void:
	
	room_manager.set_initial_room("SafeRoom")
	
	Globals.house = self
	Globals.player = player
	Globals.room_manager = room_manager
	Globals.item_manager = room_manager.item_manager
	Globals.key_manager = room_manager.key_manager
	
	room_manager.changed_room.connect(active_menu)

func _process(delta: float) -> void:
	if camera.enabled:
		camera.global_position = follow.global_position

# Como o canvasLayer tem que tá na cena main, é ele ativa e desativa o chestMenu 
# basedo no sinal que o room_manager tem, vendo se é o saferoom
func active_menu():
	var is_safe_room = room_manager.current_room.name == "SafeRoom"
	$ChestMenuInterativa/ChestMenu.set_process(is_safe_room)
	$ChestMenuInterativa.visible = is_safe_room

func set_camare_in(thing: Node2D, zoom: Vector2):
	camera.enabled = true
	room_manager.current_room.camera.enabled = false
	camera.zoom = zoom
	follow = thing
	
func desable_camera():
	camera.enabled = false
	room_manager.current_room.camera.enabled = true
