extends Node2D

class_name House

@export var player: Player
@export var room_manager: RoomManager
@export var camera: Camera2D
@export var menu_manager: MenuManager
@export var initial_position: Marker2D
@export var die_menu: DieMenu


var can_reset: bool = false

var follow: Node2D

func _ready() -> void:
	
	room_manager.set_initial_room("SafeRoom")
	player.global_position = initial_position.global_position
	
	Globals.house = self
	Globals.player = player
	Globals.room_manager = room_manager
	Globals.item_manager = room_manager.item_manager
	Globals.key_manager = room_manager.key_manager
	
	room_manager.changed_room.connect(active_menu)
	
	if room_manager.current_room.name == "SafeRoom":
		for door in room_manager.current_room.doors:
			door.open()
			
		process_mode = Node.PROCESS_MODE_ALWAYS
		
	die_menu.finished.connect(
		func():
			can_reset = true
	)
			

func _process(delta: float) -> void:
		
	if camera.enabled:
		if is_instance_valid(follow):
			camera.global_position = follow.global_position
		else:
			camera.enabled = false

# Como o canvasLayer tem que tá na cena main, é ele ativa e desativa o chestMenu 
# basedo no sinal que o room_manager tem, vendo se é o saferoom
func active_menu(room: Room):
	
	var is_safe_room = room.name == "SafeRoom"
	
	$MenuManager/Menus/ChestMenu.set_process(is_safe_room)
	$MenuManager/ChestMenuInteratives.visible = is_safe_room

func set_camare_in(thing: Node2D, zoom: Vector2):
	camera.enabled = true
	room_manager.current_room.camera.enabled = false
	camera.zoom = zoom
	follow = thing
	
func desable_camera():
	camera.enabled = false
	room_manager.current_room.camera.enabled = true
	
func _input(event: InputEvent) -> void:
	if die_menu.is_in_die_menu and die_menu.can_skip:		
		if Input.is_anything_pressed():
			die_menu.skip_logic()			
	if can_reset:
		if Input.is_anything_pressed():
			restart()			
		
		
func restart():
	
	if Globals.is_reseting: return
	
	Globals.is_reseting = true
	
	player.reset()
	
	menu_manager.reset()
	
	room_manager.reset()
	
	room_manager.round_manager.reset()
	
	room_manager.item_manager.reset()

	player.global_position = initial_position.global_position
	player.can_dash = false   
	
	for door in room_manager.current_room.doors:
		door.open()
		
	get_tree().paused = false
	
	Globals.conquited_coins = 0
	die_menu.part = 0
	die_menu.can_skip = false
	can_reset = false
	
	reseted.emit()
	

	
	await get_tree().process_frame
	
	Globals.is_reseting = false
	
signal reseted
