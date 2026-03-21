extends Menu

class_name DieMenu

@export var house: House
@export var anim: AnimationPlayer

@export var a_coins: Label
@export var c_coins: Label
@export var ene_count: Label

@export var to_set_visible_node: Control

var timer: float = 0.0
var duration: float = 0.0
var is_awaiting: bool = false

var original_c_coin_pos: Vector2

# new

var stage: int = 1
var progress: float = 0.0
var progress_scale: int = 250


func _ready() -> void:
	original_c_coin_pos = c_coins.global_position
	reset()
	
func reset():
	c_coins.global_position = original_c_coin_pos
	Globals.conquited_coins = 0

func _process(delta: float) -> void:
	super._process(delta)

func enable_state(delta: float):
	match stage:
		1: 
			aux_var["can_skip_count"] += 1
			if aux_var["can_skip_count"] >= aux_var["can_skip_limit"]:
				aux_var["can_skip"] = true
			if Input.is_anything_pressed() and aux_var["can_skip"]: 
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
			
			to_set_visible_node.visible = true
			
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
			
			aux_var["can_skip_count"] = 0
			aux_var["can_skip_limit"] = 50
			aux_var["can_skip"] = false
		MenuState.DESABLE:
			to_set_visible_node.visible = false
			stage = 1
			c_coins.global_position = aux_var["original_c_coin_pos"]
			aux_var = {}
			anim.play("2")
			anim.seek(0.0, true)
			anim.stop()
	current_state = state

func set_visi(mode: bool, type: int = 0):	
	for child in anim.get_children():
		if child.name.contains(str(type)) or type == 0:
			for c in child.get_children():
				c.visible = mode
						
