extends Area2D

class_name Bullet

@export var light: Area2D
@export var timer_to_exit: Timer

var is_shot = false
var shot_dir: Vector2
var is_stuck = false
var ene_stuck: Enemy
var all_ene_on_light = []
var time_to_take_damage = 2.5
var damage = 100
var time_remain = 5

func _ready() -> void:
	
	#collision_layer = Globals.collision_map["no_player_but_damage"] | Globals.collision_map["enemy"]
	#collision_mask = Globals.collision_map["no_player_but_damage"] | Globals.collision_map["enemy"]	
	#
	#light.collision_layer = Globals.collision_map["no_player_but_damage"] | Globals.collision_map["enemy"]
	#light.collision_mask = Globals.collision_map["no_player_but_damage"] | Globals.collision_map["enemy"]
	#
	
	collision_layer = Globals.layers["player"] | Globals.layers["enemy"]
	collision_mask = Globals.layers["enemy"] | Globals.layers["player"] | Globals.layers["ghost"]
	
	light.collision_layer = Globals.layers["player"] | Globals.layers["enemy"]
	light.collision_mask = Globals.layers["enemy"] | Globals.layers["player"] | Globals.layers["ghost"]
	
	light.set_process(false)
	
func _process(delta: float) -> void:
	
	#print("b layer: ", light.collision_layer)
	#print("b mask: ", light.collision_mask)
	
	for ene in all_ene_on_light:
		if ene["time"] >= time_to_take_damage:
			ene["ene"].take_damage(damage)
			ene["time"] = 0
			continue
		
		ene["time"] += delta
	
	if is_shot:
		position += shot_dir * 2
		rotate(0.5)
	
	if is_stuck:
		if is_instance_valid(ene_stuck):
			global_position = ene_stuck.body.global_position
		else:
			queue_free()
		
func _on_body_entered(body: Node2D) -> void:
	
	var ene = body.get_parent() as Enemy
	if ene == null: return
	
	if ene_stuck != null: return
	
	ene.enemy_die.connect(_free)
	
	if ene.is_wrapped:
		timer_to_exit.stop()
	
	timer_to_exit.start()
	
	ene.is_wrapped = true
		
	is_shot = false
	is_stuck = true
	
	ene_stuck = ene
	
	light.visible = true

func _insert_ene_on_list(body: Node2D) -> void:
	var ene = body.get_parent() as Enemy
	if ene == null: return
	all_ene_on_light.append({"ene": ene, "time": 0.0})
	print(all_ene_on_light)

func _delete_ene_on_list(body: Node2D) -> void:
	var ene = body.get_parent() as Enemy
	if ene == null: return
	for enemy in all_ene_on_light:
		if enemy["ene"] == ene:
			all_ene_on_light.erase(enemy)
	print("saiu: ", all_ene_on_light)

func _free():
	ene_stuck.is_wrapped = false
	queue_free()
