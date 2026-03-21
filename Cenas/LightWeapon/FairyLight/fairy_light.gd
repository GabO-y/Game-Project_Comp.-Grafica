extends LightWeapon

class_name FairyLight

var can_shoot: bool = true
var aux_frames: int = 0

func _ready() -> void:
	attributes["damage"] = CompostAtrribute.new()
	attributes["frames_to_damage"] = CompostAtrribute.new()
	attributes["frames_coldown_shoot"] = CompostAtrribute.new()
	
	attributes["frames_to_damage"].set_attr("value", 50, 95)
	attributes["frames_to_damage"].set_attr("price", 100, 10)
	
	attributes["frames_coldown_shoot"].set_attr("value", 20, 50)
	attributes["frames_coldown_shoot"].set_attr("price", 100, 10)
	
	attributes["damage"].set_attr("value", 10, 2)
	attributes["damage"].set_attr("price", 150, 10)
	
func enable_state(delta: float):
	
	var dir: Vector2 = get_dir()
	
	rotation = dir.angle()
	if not can_shoot:
		aux_frames += 1
		if aux_frames > attributes["frames_coldown_shoot"].get_attr("value"):
			can_shoot = true
		return
	if Input.is_action_just_pressed("shoot_bullet"):
		shoot(dir)
		can_shoot = false
		aux_frames = 0
		
	if Input.is_action_just_pressed("ui_toggle_armor"):
		setup_state(LightWeaponState.DESABLE)
		
func shoot(dir: Vector2):
	
	
	var bullet: FairyLightBullet = load("res://Cenas/LightWeapon/FairyLight/BulletFairyLight/FairyLightBullet.tscn").instantiate()
	Globals.room_manager.current_room.add_child(bullet)
	
	bullet.global_position = global_position
	bullet.fairy_light = self
	bullet.dir = dir
	bullet.start()
