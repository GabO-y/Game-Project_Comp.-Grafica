extends Menu

class_name FinishMenu

@export var particles: Array[CPUParticles2D]
@export var anim: AnimationPlayer
@export var labels_node: Control
@export var labels: Array
@export var time_label: Label

var particles_space: float = 128.0

var duration: float = 3.0
var timer: float = 0.0
var check_process: bool = false
var can_reset: bool = false

var min_sec = {}

func _ready() -> void:
	for label in labels_node.get_children():
		labels.append(label)
	#set_active(false)
	#set_process(false)
	
func _process(delta: float) -> void:
	
	super._process(delta)
	return
	
	if timer >= duration:
		can_reset = true
		timer = 0.0
		set_process(false)
		
	timer += delta

func enable_state(delta: float):
	var stage: int = aux_var["stage"]
	match stage:
		1:
			var p: float = aux_var["progress"]
			var cam: Camera2D = aux_var["cam"]
			
			Globals.player.body.global_position = aux_var["original_player_pos"] + (aux_var["dir"] * aux_var["dist"] * p)
			Globals.player.body.scale = Vector2.ONE + aux_var["scale_target"] * p
			aux_var["progress"] +=  aux_var["delta"]
			rotation_player_animation()
			if aux_var["progress"] > 1.0:
				aux_var["stage"] += 1
		2:
			rotation_player_animation()
			clock_effect_animation()
			if aux_var["can_skip"]:
				if Input.is_anything_pressed():
					Globals.player.body.remove_child(aux_var["particles_node"])
					Globals.house.reset()
					Globals.house.inital_menu.setup_state(MenuState.ENABLE)
					setup_state(MenuState.DESABLE)
					return

func setup_state(state: MenuState):
	match state:
		MenuState.ENABLE:
			


			
			labels_node.visible = true
			anim.play("1")
			
			Globals.player.setup_state(Player.PlayerState.MENU)
			Globals.weapon_manager.selected.can_toggle = false
			Globals.weapon_manager.selected.setup_state(LightWeapon.LightWeaponState.DESABLE)
			
			var p_quant: int = int(get_viewport().size.x / particles_space)
			var delta_space: float = particles_space 
			var current_pos: Vector2 = Vector2(delta_space / 2.0, 0.0)
			
			var particles_node: Node2D = Node2D.new()
			aux_var["particles_node"] = particles_node
			
			var player: Player = Globals.player
			
			player.body.add_child(particles_node)
			player.hud_node.visible = false

			aux_var["stage"] = 1
			aux_var["cam"] = Globals.room_manager.current_room.camera
			aux_var["frames_limit"] = 200.0
			
			aux_var["game_time"] = Globals.house.calc_game_time_sec()

			aux_var["frames_rotate_limit"] = 50
			aux_var["frames_clock_effect_limit"] = 300

			aux_var["frames_rotate"] = aux_var["frames_limit"]
			aux_var["frames_clock_effect"] = 0
			aux_var["current_second"] = 0
			
			aux_var["can_skip"] = false
			

			aux_var["player_dir"] = {
				1: Vector2(-1, -1),
				2: Vector2(1, -1),
				3: Vector2(1, 1),
				4: Vector2(-1, 1)
			}
			
			aux_var["player_stage_dir"] = 1
			
			aux_var["dir"] = Globals.player_pos().direction_to(aux_var["cam"].global_position)
			aux_var["dist"] = Globals.player_pos().distance_to(aux_var["cam"].global_position)
			aux_var["original_player_pos"] = Globals.player_pos()
			
			aux_var["scale_target"] = Vector2(4, 4)
			
			aux_var["delta"] = 1.0 / aux_var["frames_limit"]
			aux_var["progress"] = 0.0
			
			for i in range(p_quant):
				var cpu_p: CPUParticles2D = CPUParticles2D.new()
				particles_node.add_child(cpu_p)
				
				cpu_p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
				cpu_p.emission_sphere_radius = particles_space
				
				cpu_p.emitting = true
				cpu_p.amount = 100
				cpu_p.lifetime = 20.0
				cpu_p.gravity = Vector2(0.0, -10.0)
				cpu_p.scale_amount_max = 5.0
				cpu_p.global_position = current_pos + Vector2(delta_space * i, Globals.player_pos().y * 3.5)
				cpu_p.process_mode = Node.PROCESS_MODE_ALWAYS
		MenuState.DESABLE:
			
			labels_node.visible = false			
			Globals.player.hud_node.visible = true
			aux_var = {}
			
	current_state = state

func rotation_player_animation():
	if aux_var["frames_rotate"] >= aux_var["frames_rotate_limit"]:
		aux_var["frames_rotate"] = 0
		if aux_var["player_stage_dir"] >= 4:
			aux_var["player_stage_dir"] = 0
		aux_var["player_stage_dir"] += 1
		if Globals.player.body.velocity != Vector2.ZERO:
			Globals.player.body.velocity = Vector2(0, 0)
		Globals.player.last_direction = aux_var["player_dir"][aux_var["player_stage_dir"]]
		Globals.player.animation_logic()
	aux_var["frames_rotate"] += 1
	
func clock_effect_animation():
	
	if aux_var["frames_clock_effect"] > aux_var["frames_clock_effect_limit"]:
		if not aux_var["can_skip"]:
			aux_var["can_skip"] = true
		return
		
	var p: float = aux_var["frames_clock_effect"] as float / aux_var["frames_clock_effect_limit"]
	
	var s: int = aux_var["game_time"] * p


	var text_time: String = sec_to_min(s) if s < 60 * 60 else sec_to_hour(s)
	

	time_label.text = text_time
	aux_var["frames_clock_effect"] += 1

func sec_to_min(s: int) -> String:
	var r: String
	var m: int = s / 60
	
	if m < 10:
		r += "0"
	r += str(m, ":")
	s -= 60 * m
	if s < 10: 
		r += "0"
	r += str(s)
		
	return r

func sec_to_hour(s: int) -> String:
	var r: String 
	var h: int = int(s / (60 * 60))
	s -= h * 60 * 60
	if h < 10:
		r += "0"
	r += str(h, ":")
	r += sec_to_min(s)
	return r
