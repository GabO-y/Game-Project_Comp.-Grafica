extends PowerUp

class_name LightBallPowerUp

@export var light_area: Area2D

var rotation_length: float = 5.0

var rotation_frames_time: int = 1
var frames: int = 0

var radius: float = 50.0
var r: float = 0.0

var current_dir: Vector2 = Vector2.LEFT

func _ready() -> void:
	light_area.collision_layer = Globals.layers["player"]
	light_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]

func _process(delta: float) -> void:
	if frames > rotation_frames_time:
		var dir: Vector2 = current_dir.rotated(r)
		global_position = dir * radius + Globals.player_pos()
		r += deg_to_rad(rotation_length)
		if r > deg_to_rad(360.0):
			r -= deg_to_rad(360.0)
		frames = 0
	frames += 1
	
func apply():
	Globals.player.power_up_node.add_child(self)
	Globals.power_up_manager.power_up_in_scene["LightBall"].append(self)
	Globals.player._organizate_light_balls()
	
func _ene_enter_light(body: Node2D) -> void:
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		ene.take_damage(2)
