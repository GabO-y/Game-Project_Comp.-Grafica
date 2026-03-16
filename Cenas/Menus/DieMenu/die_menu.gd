extends Menu

class_name DieMenu

@export var house: House
@export var anim: AnimationPlayer

var can_skip: bool = true
var can_skip_1: bool = false
var can_skip_2: bool = false
var can_skip_3: bool = false

var can_reset: bool = false

@export var a_coins: Label
@export var c_coins: Label
@export var ene_count: Label

var timer: float = 0.0
var duration: float = 0.0
var is_awaiting: bool = false

var original_c_coin_pos: Vector2

var final_results: Dictionary

# new

var stage: int = 1
var progress: float = 0.0
var progress_scale: int = 250
var aux_var: Dictionary

func _ready() -> void:
	original_c_coin_pos = c_coins.global_position
	reset()
	
func reset():
	set_visi(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	c_coins.global_position = original_c_coin_pos
	Globals.conquited_coins = 0

func _process(delta: float) -> void:
	super._process(delta)
	return
	if Input.is_anything_pressed():
		if can_skip_1:
			can_skip_1 = false
			skip_1()
		elif can_skip_3:
			can_skip_3 = false
			skip_3()
		elif can_reset:
			can_reset = false
			house.reset()
	if is_awaiting:
		if timer >= duration:
			is_awaiting = false
			timer = 0.0
			match final_results["part"]:
				
				1:
					can_skip_1 = true
					
					set_process_input(true)
					set_process_unhandled_input(true)
					set_process_unhandled_key_input(true)
				2:
					can_skip_3 = true
				"reset":
					can_reset = true
		else:
			timer += delta
	
#func _input(event: InputEvent) -> void:
	#
	#if event is InputEventMouse:
		#if event.button_mask == 0:
			#return
	#
	#if can_skip_1:
		#can_skip_1 = false
		#skip_1()
	#elif can_skip_3:
		#can_skip_3 = false
		#skip_3()
	#elif can_reset:
		#pass

func enable_state(delta: float):
	match stage:
		1: 
			if can_skip and Input.is_anything_pressed(): 
				c_coins.text = str(Globals.conquited_coins)
				ene_count.text = str(Globals.enemies_defalted)
				progress = 1.0
				anim.seek(anim.current_animation_length + 1, true)
				anim.play("2")
				anim.seek(anim.current_animation_length + 1, true)
				var player: Player = Globals.player
				player.anim.frame = player.anim.animation.length()
				stage = 2				
			if progress == 0.0:
				var s: float = delta * progress_scale
				var d: float = anim.get_animation("1").length + 0.2
				var speed: float = d / s
				anim.play("1", -1, speed)
			Globals.player.body.global_position = (
				aux_var["last_player_pos"] + (aux_var["dir"] * (aux_var["dist"] * progress))
				)
			Globals.player.body.scale = (
				Vector2(1, 1) + (aux_var["scale_target"] * progress)
			)
			progress += (1.0 / progress_scale)
			if progress > 1.0:
				if anim.is_playing():
					anim.seek(anim.current_animation_length + 1, true)
				stage += 1
				progress = 0.0
		2: 
			if progress == 0.0:
				var s: float = delta * progress_scale
				var d: float = anim.get_animation("2").length + 0.2
				var speed: float = d / s
				anim.play("2", -1, speed)
			progress += (1.0 / progress_scale)
			c_coins.text = str(int(Globals.conquited_coins * progress))
			ene_count.text = str(int(Globals.enemies_defalted * progress))
			if progress > 1:
				if anim.is_playing():
					anim.seek(anim.current_animation_length + 1, true)
					anim.seek(0.0)
				stage += 1
				progress = 0.0
		3: 
			progress += (1.0 / progress_scale * 10.0)
			a_coins.text = str(int((Globals.player.coins - Globals.conquited_coins) + Globals.conquited_coins * progress))
			c_coins.global_position = aux_var["original_c_coin_pos"] + (aux_var["dir_to_a_coin"] * aux_var["dist_to_a_coin"] * progress)
			c_coins.modulate = Color(1, 1, 1, 1 - progress)
			if progress > 1:
				stage += 1
		4: 
			if Input.is_anything_pressed():
				house.reset()
				setup_state(MenuState.DESABLE)
		
func setup_state(state: MenuState):
	match state:
		MenuState.ENABLE:
			
			progress = 0.0
			Globals.player.anim.play("die", 2.0)
			
			a_coins.text = str(Globals.player.coins - Globals.conquited_coins)
			
			Globals.player.current_state = Player.PlayerState.MENU
			
			Globals.player.anim.z_index = 2
			Globals.player.body.collision_layer = 0
			Globals.player.body.collision_layer = 0
			Globals.player.setup_state(Player.PlayerState.MENU)
			
			var cam: Camera2D = Globals.room_manager.current_room.camera
			
			var cam_pos: Vector2 = cam.global_position
			var dist: float = cam_pos.distance_to(Globals.player_pos())
			
			var real_view: Vector2 = get_viewport().size 
			real_view /= cam.zoom
			
			var pos_target: Vector2 = cam_pos - Vector2(0.0, real_view.y / 5)
			
			set_visi(true)
			
			aux_var["dist"] = Globals.player_pos().distance_to(pos_target)
			aux_var["dir"] = Globals.player_pos().direction_to(pos_target)

			aux_var["scale_target"] = Vector2(4, 4)
			aux_var["last_player_pos"] = Globals.player_pos()
			
			aux_var["original_c_coin_pos"] = c_coins.global_position
			aux_var["dir_to_a_coin"] = c_coins.global_position.direction_to(a_coins.global_position)
			aux_var["dist_to_a_coin"] = c_coins.global_position.distance_to(a_coins.global_position)
			
			set_active(true)
		MenuState.DESABLE:
			stage = 1
			c_coins.global_position = aux_var["original_c_coin_pos"]
			set_active(false)
			anim.play("2")
			anim.stop()
			anim.seek(0.0, true)
		
			
	current_state = state

func skip_1():
	
	final_results["tween"].stop()
	
	Globals.player.scale = final_results["player_scala"]
	Globals.player.body.global_position = final_results["player_pos"]
	
	anim.seek(anim.current_animation_length + 1000, true)
	Globals.player.anim.set_frame_and_progress(1000, 1000)
	
	start_anim_2()
			
func skip_3():
	
	can_skip_3 = false
		
	final_results["tween"].stop()
	
	ene_count.text = str(Globals.enemies_defalted)
	
	anim.seek(anim.current_animation.length() + 1000, true)
	anim.play("3")
		
	anim.seek(anim.current_animation.length() + 1000, true)

	a_coins.text = str(Globals.player.coins)
	
	final_results["part"] = "reset"
	duration = 0.5
	is_awaiting = true
				
func start_anim_1():
	
	Globals.house.menu_manager.is_in_menu = true
	
	anim.play("1")
	final_results["part"] = 1

	part_1_tweens()
	
	final_results["tween"].finished.connect(start_anim_2)
	
	timer = 0.0
	duration = 0.5
	is_awaiting = true
		
func start_anim_2():
		
	final_results["part"] = 2

	anim.play("2")
	
	set_visi(true, 2)
	
	a_coins.text = str(Globals.player.coins - Globals.conquited_coins, " + ")
	
	part_2_tweens()
	
	final_results["tween"].finished.connect(start_anim_3)
	
	duration = 0.5
	is_awaiting = true	
	
func start_anim_3():
	
	final_results["type"] = 3
	c_coins.text = str(Globals.conquited_coins)
	
	part_3_tweens()
	
	final_results["tween"].finished.connect(
		func():
			
			can_skip_3 = false
			
			c_coins.visible = false
			a_coins.text = str(Globals.player.coins)
			
			final_results["part"] = "reset"
			duration = 0.5
			is_awaiting = true	
	)
	
func part_3_tweens():
	
	var tween = create_tween()
	final_results["tween"] = tween

	tween.tween_method(move_c_coin, 0.0, 1.0, 0.3)
	
func move_c_coin(t: float):
	c_coins.global_position = c_coins.global_position.move_toward(a_coins.global_position, t * 10)
	if c_coins.global_position.distance_to(a_coins.global_position) < 5:
		c_coins.visible = false
	
func part_2_tweens():
	
	var tween = create_tween()
	tween.set_parallel()
	
	final_results["tween"] = tween
	
	var duration: float = 5.0
	
	tween.tween_method(update_coins_label, 0.0, 1.0, duration)
	tween.tween_method(update_ene_defalted, 0.0, 1.0, duration)

func update_coins_label(t: float):
	c_coins.text = str(int(Globals.conquited_coins * t))

func update_ene_defalted(t: float):
	ene_count.text = str(int(Globals.enemies_defalted * t))
	
func part_1_tweens():
	
	set_visi(true, 1)
	
	var tween = create_tween()
	tween.set_parallel()
	
	final_results["player_pos"] = house.room_manager.current_room.camera.global_position + Vector2(0, -30)
	
	final_results["player_scala"] = Vector2(2.5, 2.5)
	final_results["tween"] = tween
	
	var durarion: float = 5.0
	
	tween.tween_property(Globals.player.body, "global_position", final_results["player_pos"], durarion)
	tween.tween_property(Globals.player, "scale", final_results["player_scala"], durarion)
	
	Globals.player.anim.play("die")
	
func set_visi(mode: bool, type: int = 0):	
	for child in anim.get_children():
		if child.name.contains(str(type)) or type == 0:
			for c in child.get_children():
				c.visible = mode
						
