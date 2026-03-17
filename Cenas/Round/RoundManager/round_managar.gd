extends Node2D

class_name RoundManagar

@export var ene_spawn_node: Node2D
@export var timer: Timer

var room_manager: RoomManager

var spawned_enemies: Array[Enemy]

var level: int = 0

var ene_quant: SimpleAttribute = SimpleAttribute.new(10, 1, 8)
var current_quant_ene: int = 0

var is_in_round: bool = false

func _ready() -> void:
	set_process(false)
	
func _process(delta: float) -> void:
	if spawned_enemies.is_empty():
		for ene in ene_spawn_node.get_children():
			ene_spawn_node.remove_child(ene)
		round_finished.emit()
		is_in_round = false
		set_process(false)
			
func spawn_random_enemy():
	
	var spawners: Array[Spawn] = room_manager.current_room.spaweners
	
	var i: int = randi_range(0, spawners.size() - 1)
	var s: Spawn = spawners.get(i)
	var ene: Enemy = s.spawn(["Skeleton", "Zombie", "Ghost"].pick_random(), 1)
	
	ene.enemy_die.connect(
		func(ene):
			Globals.item_manager.drop("Coin", ene.body.global_position)
			spawned_enemies.erase(ene)
	)
	
	spawned_enemies.append(ene)
	ene_spawn_node.add_child(ene)

func start_random_round():
	if room_manager.current_room is BossRoom or is_in_round: 
		return
	is_in_round = true
	set_process(false)
	level += 1
	current_quant_ene = 0
	timer.start()

func _on_timer_timeout() -> void:
	if current_quant_ene >= ene_quant.get_value(level):
		timer.stop()
		set_process(true)
	else:
		spawn_random_enemy()
		current_quant_ene += 1
		
func reset():
	level = 0
	for ene in ene_spawn_node.get_children():
		ene_spawn_node.remove_child(ene)
	spawned_enemies.clear()

signal round_finished
#
#signal reset_rounds
#
#class Round extends Node2D:
		#
	#var manager: RoundManagar
		#
	#var exes: Array[Exe]
	#var _can_consume_exe: bool = true
	#var _current_exe: Exe
	#var _is_last_exe: bool = false
	#
	#func _ready() -> void:
		#set_process(false)
		#manager.reset_rounds.connect(queue_free)
		#
	#
	#func add_exe(exe: Exe):
		#exes.append(exe)
		#
	#func play():
		#set_process(true)
		#
	#func _process(delta: float) -> void:
		#
		#if _can_consume_exe:
			#consume_exe()
			#_can_consume_exe = false
		#elif _current_exe.is_finished:
			#
			#exes.erase(_current_exe)
			#
			#if is_finish():
				#finished.emit()
				#set_process(false)
				#return
			#
			#_can_consume_exe = true
		#else:
			#_current_exe.play(delta)
#
	#func _check_finish():
		#if is_finish():
			#finished.emit()
			#set_process(false)
#
	#func is_finish():
	#
		#if exes.size() > 0:
			#return false
	#
		#if _current_exe is Horder:
			#print(Globals.player.current_ene_defalut, "/", Globals.ene_to_default)
			#if Globals.player.current_ene_defalut < Globals.ene_to_default:
				#return false
					#
		#if _current_exe is Await:
			#if _current_exe.time > 0.0:
				#return false
#
		#return true
		#
	#func consume_exe():
		#
		#if exes.size() <= 0:
			#set_process(false)
			#return
			#
		#if exes.size() == 1:
			#_is_last_exe = true
		#
		#_current_exe = exes.get(0)
		#exes.remove_at(0)
		#
	#func reset():
		#for exe in exes:
			#if is_instance_valid(exe):
				#exe.is_finished = true
				#exe.reset()
				#exes.erase(exe)
				#exe.queue_free()
		#queue_free()
		#
	#signal finished
			#
		#
#class Exe:
	#
	#var is_finished: bool = false
	#var round: Round
	#
	#func play(delta: float):
		#pass
		#
	#func reset():
		#pass
	#
#class Horder extends Exe:
		#
	#var ene_name: String
	#var quantity: int
	#var time_spawn: float
	#var level: int
	#var spawns: Array[Spawn]
	#var count: int = 0
	#var is_first: bool = true
	#
	#var _timer: float = 0.0
	#var _ene_spawned: Array[Enemy]
	#
	#func play(delta):
		#if quantity <= 0:
			#is_finished = true
		#if is_finished: return
		#if _timer >= time_spawn:
			#for s in spawns:
				#var ene = s.spawn(ene_name, level)
				#_ene_spawned.append(ene)
				#ene._update_sound(_ene_spawned)
				#ene.enemy_die.connect(
					#func(ene: Enemy):
						#Globals.player.current_ene_defalut += 1
						#Globals.enemies_defalted += 1
						#round._check_finish()
				#)
				#round.finished.connect(
					#ene.queue_free
				#)
				#round.manager.reset_rounds.connect(
					#func():
						#if ene:
							#ene.queue_free()
				#)
			#_timer = 0.0
			#quantity -= 1
		#_timer += delta
		#
#class Await extends Exe:
	#var time: float
	#var _timer: float = 0.0
	#func play(delta):
		#if _timer >= time:
			#is_finished = true
		#if is_finished:
			#return
		#_timer += delta
		#
	#
	
