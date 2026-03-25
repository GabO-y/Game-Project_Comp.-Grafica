extends PowerUp

class_name FairyPowerUp

var current_state: FairyState = FairyState.WATING

var wating_frames: int = 50
var moving_frames: int = 50
var frames: int = 0

var distance_radius: float = 40.0
var target_pos: Vector2
var speed: float = 1.0

func _physics_process(delta: float) -> void:
	match current_state:
		FairyState.MOVING:
			moving_state(delta)
		FairyState.WATING:
			if frames > wating_frames:
				setup_state(FairyState.ATTACKING)
		FairyState.ATTACKING:
			attack()
	frames += 1
			
func moving_state(delta: float):
	var dist: float = global_position.distance_to(target_pos)
	if dist < 1.0:
		frames += 1
	else:
		var dir: Vector2 = global_position.direction_to(target_pos)
		global_position += dir * speed
	if frames > moving_frames:
		setup_state(FairyState.WATING)
		return
	
func attack():
	
	var ene: Enemy = Globals.get_random_enemy()
	if ene:
		var bullet: FairyPowerUpBullet = load("res://Cenas/PowerUps/FairyPowerUp/FairyPowerUpBullet/FairyPowerUpBullet.tscn").instantiate()
		Globals.room_manager.current_room.add_child(bullet)
		var dir: Vector2 = global_position.direction_to(ene.body.global_position)
		bullet.global_position = global_position
		bullet.dir = dir
		bullet.start()
		
	setup_state(FairyState.MOVING)
	
func setup_state(state: FairyState):
	match state:
		FairyState.MOVING:
			set_random_target()
			frames = 0
		FairyState.WATING:
			frames = 0
	current_state = state
	
func set_random_target():
	var dir: Vector2 = Globals.get_random_dir()
	target_pos = dir * randf_range(1.0, distance_radius) + Globals.player_pos()
	
func apply():
	Globals.player.power_up_node.add_child(self)
	Globals.power_up_manager.power_up_in_scene["Fairy"].append(self)
	
enum FairyState {MOVING, WATING, ATTACKING}
