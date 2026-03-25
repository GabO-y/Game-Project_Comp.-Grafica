extends Node

var current_room: Room
var last_scene
var can_teleport = true
var player: Player
var die = false
var already_keys = []
var is_get_animation = false
var center_pos: Vector2
var special_time_ghost_run = 2
var curren_menu: Control
var backlayer_filter: CanvasModulate

var current_level:int = 0
var quantity_ene:  float = 1
var quantity_horder: float = 1
var quantity_spawns: float = 1

var total_ene_defaeted: int = 0
var ene_defaeted_current_run: int = 0

var conquited_coins: int = 0

var room_manager: RoomManager
var item_manager: ItemManager
var key_manager: KeyManager
var round_manager: RoundManagar
var weapon_manager: WeaponManager
var audio_manager: AudioManager
var power_up_manager: PowerUpManager
var house: House

var color_brigthness_target: Color 

var is_mute: bool = false

var god_vars: Dictionary

var global_brightness: float = 0.5

var multiplier_coins_bonus: float = 1.0

var layers = {
	"player" : 1 << 0,
	"enemy" : 1 << 1,
	"boss": 1 << 2,
	"wall_boss": 1 << 3,
	"current_wall": 1 << 4,
	"out_room_boss": 1 << 5,
	"ghost": 1 << 6,
	"no_collision_wall": 1 << 7,
	"weapon": 1 << 8,
	"dash_moment": 1 << 9,
	# Para uns obstaculos nos quartos (toy_library)
	"utils_wall": 1 << 10
}


var is_reseting: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	
	if die:
		if Input.is_key_label_pressed(KEY_SPACE):
			get_tree().reload_current_scene()
			get_tree().paused = false
			die = false
		
func desable_room():
	current_room.desable()
	
func enable_room():
	current_room.enable()
	
func set_teleport(can: bool):
	if can:
		get_tree().create_timer(0.5).timeout
		Globals.can_teleport = true
	else:
		Globals.can_teleport = false

func is_clean_room():
	return current_room.is_clean()

func update_room_light():
	current_room._update_doors_light()
	
#func change_room():
	#current_room._update_doors_light()
	#current_room.update_layers()
	#if current_room.finish: return

func time(time: float):
	return get_tree().create_timer(time).timeout

func player_pos(): 
	if !player:
		print("PLAYER NULL")
		return Vector2(0, 0)
	return player.body.global_position

func get_special_time_ghost_run():
	special_time_ghost_run += 0.5
	return special_time_ghost_run

func dir_to(current: Vector2, target: Vector2):
	return current.direction_to(target)
	
func debug_area(area: Area2D):
	print(area.get_path())
	print("\tlayer: ", area.collision_layer)
	print("\tmask: ", area.collision_mask)
	
func get_random_dir() -> Vector2:
	return Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()
	
func get_current_room() -> Room:
	return room_manager.current_room
	
func get_current_room_cam() -> Camera2D:
	return get_current_room().camera

func test_collsion(c: CollisionObject2D):
	print("--------------------------------")
	print("name: ", c.get_parent().name)
	print("layer: ", c.collision_layer)
	print("mask: ", c.collision_mask)
	print("--------------------------------")
	
func get_player_state() -> String:
	return Player.PlayerState.find_key(player.current_state)

func get_current_room_name():
	return room_manager.current_room.name
	
func is_player(body: Node2D) -> Player:
	if body.get_parent():
		var player: Player = body.get_parent()
		if player:
			return player
	return null
	
func make_drop_curve(first: Vector2, last: Vector2, heigth: float):
	
	var dir: Vector2 = first.direction_to(last)
	var dist: float = first.distance_to(last)
	var center: Vector2 = first + dir * dist / 2.0
	
	center += dir.rotated(deg_to_rad(-90.0)) * heigth
	
	var curve: Curve2D = Curve2D.new()
	curve.add_point(first)
	curve.add_point(center, Vector2.LEFT * heigth * 0.3, Vector2.RIGHT * heigth * 0.3)
	curve.add_point(last)
	
	return curve
	
func get_pos_curve(curve: Curve2D, n: float):
	var points: Array = curve.get_baked_points()
	var size: int = points.size() - 1
	return points.get(int(size * n))

func get_random_enemy() -> Enemy:
	var ene: Enemy
	if round_manager.is_in_round:
		if not round_manager.spawned_enemies.is_empty():
			while not ene:
				ene = round_manager.spawned_enemies.pick_random()
	return ene

func update_brightness():
	backlayer_filter.color = lerp(Color(1,1,1), color_brigthness_target, global_brightness)
	
