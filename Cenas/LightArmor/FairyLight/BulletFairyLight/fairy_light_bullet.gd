extends Bullet

class_name FairyLightBullet

@export var light_area: Area2D

var is_stuck: bool = false
var ene_stuck: Enemy

var life_time: float = 5.0

var enemies_in_light: Array[Dictionary]

var fairy_light: FairyLight
var is_to_rotate: bool = true

func _ready() -> void:
	light_area.collision_layer = Globals.layers["armor"] | Globals.layers["player"]
	light_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]
	collision_area.collision_layer = Globals.layers["armor"] | Globals.layers["player"]
	collision_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if ene_stuck:
		global_position = ene_stuck.body.global_position
		life_time -= delta
		if ene_stuck.health <= 0:
			life_time -= delta
		if life_time <= 0 or ene_stuck.health <= 0:
			queue_free()
		for ene in enemies_in_light:
			if ene["in_light"]:
				ene["time"] += delta
			else:
				ene["time"] -= delta
			var time = ene["time"]
			if time < 0.0:
				enemies_in_light.erase(ene)
			if time > fairy_light.time_to_damage:
				ene["ene"].take_damage(fairy_light.damage)
				ene["time"] = 0.0
	elif is_to_rotate:
		rotate(deg_to_rad(20.0))
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not ene_stuck:
		queue_redraw()

func _on_collision_touch_body_entered(body: Node2D) -> void:
	if ene_stuck: return
	var ene: Enemy = body.get_parent() as Enemy
	if ene.health <= 0: return
	if ene:
		ene_stuck = ene
		is_to_move = false
		light_area.body_entered.connect(ene_enter_light)
		light_area.body_exited.connect(ene_exit_light)
		enemies_in_light.append({
			"ene": ene,
			"time": 0.0,
			"in_light": true
		})

func ene_enter_light(body: Node2D):
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		enemies_in_light.append({
			"ene": ene,
			"time": 0.0,
			"in_light": true
		})
	
func ene_exit_light(body: Node2D):
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		for e in enemies_in_light:
			if e["ene"] == ene:
				e["in_light"] = false
				break
