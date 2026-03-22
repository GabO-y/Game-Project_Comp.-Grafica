extends Node2D

class_name RoundManagar

@export var ene_spawn_node: Node2D
@export var timer: Timer

var room_manager: RoomManager

var spawned_enemies: Array[Enemy]

var level: int = 0

var ene_quant: SimpleAttribute = SimpleAttribute.new(20, 1, 8)
var current_quant_ene: int = 0

var is_in_round: bool = false

var aux_var: Dictionary

func _ready() -> void:
	set_physics_process(false)
	
func _process(delta: float) -> void:
	audio_enemies_logic()
	
func _physics_process(delta: float) -> void:
	if spawned_enemies.is_empty():
		for ene in ene_spawn_node.get_children():
			ene_spawn_node.remove_child(ene)
		round_finished.emit()
		is_in_round = false
		set_physics_process(false)
		set_process(false)
		
func spawn_random_enemy():
	var spawners: Array[Spawn] = room_manager.current_room.spaweners
	var i: int = randi_range(0, spawners.size() - 1)
	var s: Spawn = spawners.get(i)
	var ene_type: String = ["Skeleton", "Zombie", "Ghost"].pick_random()
	var ene: Enemy = s.spawn(ene_type)
	ene_spawn_node.add_child(ene)
	ene.enemy_die.connect(
		func(ene):
			Globals.item_manager.drop("Coin", ene.body.global_position)
			spawned_enemies.erase(ene)
			Globals.ene_defaeted_current_run += 1
			Globals.total_ene_defaeted += 1
			Globals.power_up_manager.ene_defeated += 1
	)
	spawned_enemies.append(ene)
	ene.level = level
	ene.update_all_status()

func start_random_round():
	if room_manager.current_room is BossRoom or is_in_round: 
		return
	is_in_round = true
	set_physics_process(false)
	set_process(true)
	level += 1
	current_quant_ene = 0
	timer.start()

func _on_timer_timeout() -> void:
	if current_quant_ene >= ene_quant.get_value(level):
		timer.stop()
		set_physics_process(true)
	else:
		spawn_random_enemy()
		current_quant_ene += 1
		
func reset():
	level = 0
	timer.stop()
	is_in_round = false
	for ene in ene_spawn_node.get_children():
		ene_spawn_node.remove_child(ene)
	spawned_enemies.clear()

func audio_enemies_logic():
	var ene_count: Dictionary
	for ene in spawned_enemies:
		var ene_name: String 
		if ene is Zombie:
			ene_name = "Zombie"
		elif ene is Ghost:
			ene_name = "Ghost"
		else:
			ene_name = "Skeleton"
			
		if not aux_var.has(ene_name):
			aux_var[ene_name] = 0
			aux_var[str(ene_name, "_limit")] = 10
		if ene_count.has(ene_name):
			ene_count[ene_name] += 1
		else:
			ene_count[ene_name] = 1
	
	var level_ene_quant: float = ene_quant.get_value(level)
	for ene_name in ene_count.keys():
		var ene_current_quant: float = ene_count[ene_name]
		var p: float = ene_current_quant / level_ene_quant
		var r: float = randf()
		var can_play: bool = aux_var[ene_name] > aux_var[str(ene_name, "_limit")]
		if can_play:
			if p >= r:
				Globals.audio_manager.play(ene_name.to_lower(), "Enemies")
				aux_var[ene_name] = 0
				var frames_tax: int = 500
				aux_var[str(ene_name, "_limit")] = randi_range(frames_tax - ((frames_tax - 100) * p), frames_tax)
		else:
			aux_var[ene_name] += 1

signal round_finished
