extends Bullet

class_name FairyLightBullet

@export var light_area: Area2D

var is_stuck: bool = false
var ene_stuck: Enemy

var enemies_in_light: Array[Dictionary]

var fairy_light: FairyLight
var is_to_rotate: bool = true

func _ready() -> void:
	light_area.collision_layer = Globals.layers["weapon"] | Globals.layers["player"]
	light_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]
	collision_area.collision_layer = Globals.layers["weapon"] | Globals.layers["player"]
	collision_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if ene_stuck:
		
		if frames > life_time_frames:
			queue_free()
			return
		else:
			frames += 1
			
		global_position = ene_stuck.body.global_position
		for ene in enemies_in_light:
			if ene["in_light"]:
				ene["frames"] += 1
			else:
				ene["frames"] -= 1
			var f: int = ene["frames"]
			if f < 0:
				enemies_in_light.erase(ene)
			if f > fairy_light.attributes["frames_to_damage"].get_attr("value"):
				ene["ene"].take_damage(fairy_light.attributes["damage"].get_attr("value"))
				ene["frames"] = 0.0
				if ene["ene"] is Boss:
					frames = life_time_frames + 1
	elif is_to_rotate:
		rotate(deg_to_rad(20.0))
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not ene_stuck:
		queue_redraw()

func _on_collision_touch_body_entered(body: Node2D) -> void:
	
	if ene_stuck: return
	var ene: Enemy = body.get_parent() as Enemy
	if ene.heart <= 0: return
	
	if Globals.god_vars["insta_ene_kill"]:
		ene.die()
		return
	
	if ene:
		life_time_frames = 200
		frames = 0
		ene_stuck = ene
		is_to_move = false
		light_area.body_entered.connect(ene_enter_light)
		light_area.body_exited.connect(ene_exit_light)
		enemies_in_light.append({
			"ene": ene,
			"frames": 0,
			"in_light": true
		})

func ene_enter_light(body: Node2D):
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		enemies_in_light.append({
			"ene": ene,
			"frames": 0,
			"in_light": true
		})
	
func ene_exit_light(body: Node2D):
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		for e in enemies_in_light:
			if e["ene"] == ene:
				e["in_light"] = false
				break
