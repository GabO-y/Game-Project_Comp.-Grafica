extends Node2D

class_name House

@export var player: Player

@export var room_manager: RoomManager
@export var menu_manager: MenuManager
@export var audio_manager: AudioManager

@export var camera: Camera2D
@export var initial_position: Marker2D
@export var backlayer_filter: Node2D

@export var die_menu: DieMenu
@export var finish_menu: FinishMenu
@export var inital_menu: InitialMenu
@export var tutorial_menu: TutorialMenu
@export var god_menu: GodMenu

@export var is_skip_initial_menu: bool = false
@export var insta_ene_kill: bool = false
@export var can_player_die: bool = true
@export var has_key_animation: bool = true
@export var test_boss: bool = false
@export var ene_test: bool = false

@export var can_use_god_menu: bool = false

var already_finish: bool = false

var can_reset: bool = false

var follow: Node2D

var start_time: float = 0.0

var god_vars: Dictionary = {}

func _ready() -> void:
	
	Globals.house = self
	Globals.player = player
	Globals.backlayer_filter = backlayer_filter
	
	Globals.god_vars["insta_ene_kill"] = insta_ene_kill
	Globals.god_vars["can_player_die"] = can_player_die
	Globals.god_vars["has_key_animation"] = has_key_animation

	room_manager.set_initial_room("SafeRoom")
	god_menu.setup_state(Menu.MenuState.DESABLE)
	god_menu.setup()
	player.body.global_position = initial_position.global_position
	
	Globals.room_manager = room_manager
	Globals.item_manager = room_manager.item_manager
	Globals.key_manager = room_manager.key_manager
	Globals.round_manager = room_manager.round_manager
	Globals.audio_manager = audio_manager
		
	die_menu.house = self
	
	player.setup_state(Player.PlayerState.MENU)
	player._die.connect(
		func():
			die_menu.a_coins.text = str(player.coins)
			die_menu.setup_state(die_menu.MenuState.ENABLE)
			die_menu.set_active(true)
			#die_menu.start_anim_1()
	)
		
	if room_manager.current_room.name == "SafeRoom":
		for door in room_manager.current_room.doors:
			door.open()
			
	#process_mode = Node.PROCESS_MODE_ALWAYS
	
	
	if is_skip_initial_menu:
		inital_menu.setup_state(Menu.MenuState.DESABLE)
		start_time = Time.get_ticks_msec()
	else:
		inital_menu.setup_state(Menu.MenuState.ENABLE)
		
	if test_boss:
		var room = "GhostBossRoom"
		for door in room_manager.get_room("SafeRoom").doors:
			door.name = room
			break
		for door in room_manager.get_room(room).doors:
			door.name = "SafeRoom"
			break
		
		room_manager.match_doors("SafeRoom", room)
	
	if ene_test:
		var zombie: Zombie = load("res://Cenas/Enemy/Zombie/Zombie.tscn").instantiate()
		var room: Room = room_manager.current_room
		room.add_child(zombie)
		zombie.global_position = room.camera.global_position
		zombie.set_physics_process(false)
		zombie.heart = 1000000
		
	inital_menu.start_play.connect(await_initial_menu)

	
	finish_game.connect(
		func():
			finish_menu.setup_state(Menu.MenuState.ENABLE)
	)
	


	#Globals.conquited_coins = 1000
	#Globals.enemies_defalted = 500
	
func await_initial_menu():
	player.set_active(true)
	if start_time == 0.0:
		start_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if camera.enabled:
		if is_instance_valid(follow):
			camera.global_position = follow.global_position
		else:
			camera.enabled = false
			
# Como o canvasLayer tem que tá na cena main, é ele ativa e desativa o chestMenu 
# basedo no sinal que o room_manager tem, vendo se é o saferoom

func set_camare_in(thing: Node2D, zoom: Vector2):
	camera.enabled = true
	room_manager.current_room.camera.enabled = false
	camera.zoom = zoom
	follow = thing
	
func desable_camera():
	camera.enabled = false
	room_manager.current_room.camera.enabled = true
		
func reset():

	already_finish = false

	player.reset()
	
	menu_manager.reset()
	
	room_manager.reset()
	
	room_manager.round_manager.reset()
	
	room_manager.item_manager.reset()
	
	player.body.global_position = initial_position.global_position
	
	for door in room_manager.current_room.doors:
		door.open()
		
	get_tree().paused = false
		
	die_menu.reset()
		
	reseted.emit()
	
func calc_game_time_sec():
	var time = Time.get_ticks_msec() - start_time
	return time / 1000

signal finish_game
signal reseted
