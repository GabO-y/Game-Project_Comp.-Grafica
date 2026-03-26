extends Node2D

class_name House

@export var player: Player

@export var room_manager: RoomManager
@export var menu_manager: MenuManager
@export var audio_manager: AudioManager

@export var camera: Camera2D
@export var initial_position: Marker2D
@export var backlayer_filter: CanvasModulate

@export var die_menu: DieMenu
@export var finish_menu: FinishMenu
@export var inital_menu: InitialMenu
@export var tutorial_menu: TutorialMenu
@export var power_up_menu: PowerUpMenu
@export var god_menu: GodMenu

@export var is_skip_initial_menu: bool = false
@export var insta_ene_kill: bool = false
@export var can_player_die: bool = true
@export var has_key_animation: bool = true
@export var test_boss: bool = false
@export var ene_test: bool = false
@export var player_infinity_coin: bool = false

@export var can_use_god_menu: bool = false

var already_finish: bool = false

var can_reset: bool = false

var follow: Node2D

var start_time: float = 0.0

var god_vars: Dictionary = {}

var filter_color: Color = Color(67.0/255.0, 0.0, 140.0 / 255.0, 1.0)

func _ready() -> void:
	
	Globals.house = self
	Globals.player = player
	
	backlayer_filter.color = filter_color
	
	Globals.backlayer_filter = backlayer_filter
	Globals.color_brigthness_target = filter_color
	Globals.update_brightness()
	
	Globals.god_vars["insta_ene_kill"] = insta_ene_kill
	Globals.god_vars["can_player_die"] = can_player_die
	Globals.god_vars["has_key_animation"] = has_key_animation
	Globals.god_vars["player_infinity_coins"] = player_infinity_coin

	room_manager.set_initial_room("SafeRoom")
	god_menu.setup_state(Menu.MenuState.DESABLE)
	god_menu.setup()
	player.body.global_position = initial_position.global_position
	
	Globals.room_manager = room_manager
	Globals.item_manager = room_manager.item_manager
	Globals.key_manager = room_manager.key_manager
	Globals.round_manager = room_manager.round_manager
	Globals.audio_manager = audio_manager
	Globals.weapon_manager = player.weapon_manager
	
	power_up_menu.setup_state(Menu.MenuState.DESABLE)

	die_menu.house = self
	
	player._die.connect(
		func():
			die_menu.a_coins.text = str(player.coins)
			die_menu.setup_state(die_menu.MenuState.ENABLE)
	)
		
	if room_manager.current_room.name == "SafeRoom":
		for door in room_manager.current_room.doors:
			door.open()
			
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
		print(zombie.body.collision_layer)
		
	inital_menu.start_play.connect(await_initial_menu)

	finish_game.connect(
		func():
			finish_menu.setup_state(Menu.MenuState.ENABLE)
	)

func await_initial_menu():
	if start_time == 0.0:
		start_time = Time.get_ticks_msec()
				
func reset():

	already_finish = false

	player.reset()
	
	menu_manager.reset()
	
	room_manager.reset()
	
	room_manager.round_manager.reset()
	
	room_manager.item_manager.reset()
	
	player.body.global_position = initial_position.global_position
	
	Globals.ene_defaeted_current_run = 0
		
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
