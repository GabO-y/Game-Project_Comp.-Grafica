extends Item

class_name Key

@export var particles_node: CPUParticles2D

var door1: Door
var door2: Door

var is_going_to_door: bool = false

var is_key_moment: bool = false
var is_await_moment: bool = false

var finish_key_moment: bool = false
var finish_await_moment: bool = false

var key_manager: KeyManager

# new

var current_key_state: KeyState
var animation_stage: int = 1

var aux_var: Dictionary

func _ready() -> void:
	if not Globals.has_key_animation:
		use()
		queue_free()
	else:
		super._ready()
		progress_scale = 150
	
	
	
func _process(delta: float) -> void:
	

		
		
	#if Input.is_anything_pressed():
		#if is_key_moment:
			#finish_get_key()		
		#elif is_await_moment:
			#finish_await()
			
	super._process(delta)
	
func custom_state(delta: float):
	match current_key_state:
		KeyState.ANIMATION:
			animation_state(delta)
			
func animation_state(delta: float):
	match animation_stage:
		1:
			var cam: Camera2D = aux_var["room_cam"]
			cam.global_position = aux_var["original_cam_pos"] + (aux_var["dir_to_player_cam"] * aux_var["dist_to_player_cam"] * progress)
			cam.zoom = aux_var["original_zoom"] + ((aux_var["zoom_target"] - aux_var["original_zoom"]) * progress)
			
			global_position = aux_var["original_key_pos"] + (aux_var["dir_key"] * aux_var["dist_key"] * progress)
			
			progress += 1.0 / progress_scale
			if progress > 1.0:
				aux_var["curve"] = get_curve_chase()
				animation_stage += 1
				progress = 0.0
		2:
			if Input.is_anything_pressed():
				animation_stage += 1
		3:
			var curve: MyCurve = aux_var["curve"]
			
			global_position = curve.get_point(progress)
			aux_var["room_cam"].global_position = curve.get_point(progress)

			
			curve.set_p2(door1.global_position)
			
			print(aux_var["room_cam"].global_position)
		
			progress += 1.0 / progress_scale
			if progress > 1.0:
				print(aux_var["room_cam"].global_position)
				progress = 0.0
				animation_stage += 1
				use()
		4:
			if Input.is_anything_pressed():
				setup_key_state(KeyState.NORNAL)

				
func setup_key_state(state: KeyState):
	match state:
		KeyState.NORNAL:

			var cam: Camera2D = aux_var["room_cam"]
			cam.global_position = aux_var["original_cam_pos"]
			cam.zoom = aux_var["original_zoom"]
			
			Globals.room_manager.current_room.is_camera_chase = aux_var["is_camera_chase"]

			Globals.player.setup_state(Player.PlayerState.MOVING)
			queue_free()
			
		KeyState.ANIMATION:
			
			animation_stage = 1
			Globals.player.setup_state(Player.PlayerState.ANIMATION)
			Globals.player.anim.play("get_item")
			
			var room_cam: Camera2D = Globals.room_manager.current_room.camera
			
			aux_var["original_zoom"] = room_cam.zoom
			aux_var["zoom_target"] = Vector2(4, 4)
			
			aux_var["is_camera_chase"] = Globals.room_manager.current_room.is_camera_chase
			Globals.room_manager.current_room.is_camera_chase = false
			
			aux_var["room_cam"] = room_cam
			
			aux_var["dir_to_player_cam"] = room_cam.global_position.direction_to(Globals.player_pos())
			aux_var["dist_to_player_cam"] = room_cam.global_position.distance_to(Globals.player_pos())
			aux_var["original_cam_pos"] = room_cam.global_position
			
			var target_pos: Vector2 = Globals.player_pos() - Vector2(0.0, 20)
			
			aux_var["original_key_pos"] = global_position
			aux_var["dir_key"] = global_position.direction_to(target_pos)
			aux_var["dist_key"] = global_position.distance_to(target_pos)
		
			progress = 0.0
			
	current_key_state = state
	
func start_chase_player():
	super.start_chase_player()
	curve.set_t(0.007)
	
# Fazer a parte de quando a sala nao finalizadas pra que ele crie uma chave
	
func use():
	key_manager.key = null
	visible = false
	door1.open()
	
func finish_get_key():
	
	if finish_key_moment: return
	finish_key_moment = true
	
	set_go_to(door1.position)
	use_when_arrieve.connect(_open_door_and_wait)

func start_particles():
	
	var tween = create_tween()
	particles_node.visible = true

	tween.tween_property(particles_node, "amount", 100, 0.001)
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 2.0)
	
	is_key_moment = false
		
	await tween.finished
	is_await_moment = true
	
func finish_await():
	
	if finish_await_moment: return
	finish_await_moment = true
	
	is_await_moment = false
	
	Globals.player.is_getting_key = false
	set_process(false)
	
	Globals.player.set_process(true)
	Globals.player.set_physics_process(true)
	
	Globals.house.desable_camera()
	use()		
	
	finish_key_moment = false
	finish_await_moment = false
	
func _open_door_and_wait():
	
	visible = false

	door1.unlock_audio.play()
	door1.open()
	
	is_await_moment = true
	is_key_moment =  false

func collect(body: Node2D):
	if Globals.is_player(body):
		for c in area.body_entered.get_connections():
			area.body_entered.disconnect(c["callable"])
		setup_state(ItemState.CUSTOM)
		setup_key_state(KeyState.ANIMATION)
		
enum KeyState {NORNAL, ANIMATION}
	
signal use_when_arrieve
	
