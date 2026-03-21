extends Character
class_name Player

@export var weapon_node: Node2D

@export var can_die: bool = true
@export var hit_kill: bool = false
@export var body: CharacterBody2D
@export var anim: AnimatedSprite2D
@export var hit_area: Area2D
@export var knockback_anim: AnimationPlayer
@export var coins: int = 0
@export var hud_node: CanvasLayer
@export var label_coins: Label
@export var armor_node: Node2D
@export var weapon_manager: WeaponManager
@export var raycast2d_node: Node2D

var flick_aux: int = 0

var max_heart: int = 5
var hearts: int = 0

var is_invencible: bool = false
var invencible_frames_duration: float = 1.2
var invencible_duration_bonus: float = 1.0
var invencible_frames_count: float = 0

var input_vector: Vector2

var speed: float = 100
var speed_bonus: float = 1.0
var dash_speed: float = 600

var dash_frames_duration: int = 3
var dash_frames: int = 0

var dash_cooldown_frames: int = 0
var dash_cooldown_frames_duration: int = 15

var can_dash = true
var is_dashing: bool = false

var last_direction: Vector2 = Vector2.RIGHT
var dash_dir: Vector2
var dash_target_pos: Vector2

var can_teleport: bool = true

var is_on_knockback = false
var knockback_dir: Vector2
var knockback_force: int
var knockback_time = 0
var knockback_duration = 0.5

var is_dead: bool = false

@export var heart_node: Control
var hearts_control: Array[TextureRect] = []

# new 

enum PlayerState {MOVING, DASHING, KNOCKBACK, MENU, ANIMATION}
var current_state: PlayerState = PlayerState.MOVING

var d: float = 0.0
var t: float = 0.0

var can_take_damege: bool = true

var attributes: Dictionary = {}

func _ready() -> void:
	
	var tab_infos: Dictionary = {
		"life": {
			"value": {
				"max": 10.0,
				"min": 5.0
			},			
			"price": {
				"max": 100,
				"min": 15
			},
			"max_level": 6
		},
		"speed": {
			"value": {
				"max": 150.0,
				"min": 100.0
			},
			"price": {
				"max": 100,
				"min": 15
			}
		},
		"dash_duration": {
			"value": {
				"max": 6,
				"min": 3
			},
			"max_level": 5,
			"price": {
				"max": 100,
				"min": 15
			}
		},
		"dash_coldown": {
			"value": {
				"max": 8,
				"min": 15
			},
			"price": {
				"max": 100,
				"min": 15
			}
		},
		"invencible_time": {
			"value": {
				"max": 120,
				"min": 70
			},
			"price": {
				"max": 100,
				"min": 15
			}
		}
	}
	
	for attr in tab_infos.keys():
		var max_level: int = 10
		if tab_infos[attr].has("max_level"):
			max_level = tab_infos[attr]["max_level"]
		var a: CompostAtrribute = CompostAtrribute.new(max_level)
		for key in tab_infos[attr]:
			if key == "max_level":
				continue
			a.set_attr(key, tab_infos[attr][key]["max"], tab_infos[attr][key]["min"])
		attributes[attr] = a

	Globals.weapon_manager = weapon_manager
	
	hearts = max_heart
	
	update_label_coins()

	get_window().size_changed.connect(update_hearts)
	for attr in attributes.keys():
		update_status(attr)
	
	

func _physics_process(delta: float) -> void:
	match current_state:
		PlayerState.MOVING:
			var dir = get_dir_move()
			if dir != Vector2.ZERO:
				last_direction = dir
			body.velocity = dir * speed
			body.move_and_slide()
			if Input.is_action_just_pressed("ui_dash"):
				setup_state(PlayerState.DASHING)
			animation_logic()
		PlayerState.DASHING:
			dash_state(delta)
			animation_logic()
		PlayerState.KNOCKBACK:
			body.velocity = knockback_dir * knockback_force
			body.move_and_slide()
		PlayerState.MENU:
			pass
		PlayerState.ANIMATION:
			pass
			
	if not can_dash and current_state != PlayerState.DASHING:
		dash_cooldown_frames += 1
		if dash_cooldown_frames > dash_cooldown_frames_duration:
			can_dash = true
			
	if is_invencible:
		invencible_frames_count += 1
		flick()
		if invencible_frames_count > invencible_frames_duration:
			is_invencible = false
			invencible_frames_count = 0
			flick_aux = 0
			anim.modulate = Color(1, 1, 1)

func setup_state(state: PlayerState):
	
	match state:
		PlayerState.MOVING:
			body.collision_layer = Globals.layers["player"]
			body.collision_mask = Globals.layers["enemy"] | Globals.layers["current_wall"] | Globals.layers["ghost"]
			can_take_damege = true
		PlayerState.DASHING:
			if not can_dash: 
				return
			can_dash = false
			dash_frames = 0
			dash_dir = last_direction
			body.collision_layer = 0
			body.collision_mask = Globals.layers["current_wall"]
			can_take_damege = false
			Globals.audio_manager.play("dash", "Player")
		PlayerState.KNOCKBACK:
			can_take_damege = false
			knockback_time = 0.0
			anim.play("knockback")
			anim.animation_finished.connect(
				func(): 
					setup_state(PlayerState.MOVING)
					for i in anim.animation_finished.get_connections():
						anim.animation_finished.disconnect(i["callable"])
			)
	current_state = state

func dash_state(delta):
	
	body.velocity = dash_dir * dash_speed
	body.move_and_slide()
	
	dash_frames += 1
	
	if dash_frames > dash_frames_duration:
		can_dash = false
		setup_state(PlayerState.MOVING)
		dash_cooldown_frames = 0
	
func get_dir_move() -> Vector2:
	input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	input_vector.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1

	if input_vector.length() < 0.2:
		return Vector2.ZERO
	else:
		last_direction = input_vector.normalized()
		return last_direction

func animation_logic():
	
	var play: String = ""
	var dir: Vector2 = body.velocity
	if dir == Vector2.ZERO:
		play += "idle"
		dir = last_direction
	else:
		play += "walk"
		
	if dir.y < 0:
		play += "_back"
		
	anim.flip_h = dir.x > 0
	anim.play(play)
		
func knockback_animation(dir: Vector2):
	
	anim.play("knockback")
	anim.flip_h = dir.x > 0
	
	await anim.animation_finished
	
	last_direction = -dir
	last_direction.y = 1
	is_on_knockback = false

func take_damage(damage: int):
	if is_invencible or not can_take_damege or not Globals.god_vars["can_player_die"]: 
		return
	is_invencible = true
	setup_state(PlayerState.KNOCKBACK)
	hearts -= damage;
	update_hearts()
	if hearts <= 0:
		die()
	
func die():
	
	if is_dead: return
	
	Globals.weapon_manager.selected.setup_state(LightWeapon.LightWeaponState.DESABLE)
	
	get_tree().paused = true
	
	is_dead = true
	
	set_process(false)
	set_physics_process(false)
	
	_die.emit()
	
	
func flick():
	if flick_aux % 10 == 0:
		anim.modulate = Color(3, 3, 3)
	else:
		anim.modulate = Color(1, 1, 1)
	flick_aux += 1

func take_knockback(direction: Vector2, force: int):
	
	if is_invencible or is_dashing: return
		
	is_on_knockback = true
	knockback_dir = direction
	knockback_force = force
	
	knockback_animation(direction)

func _on_hit_area_body_entered(body: Node2D) -> void:
	var ene = body.get_parent() as Enemy
	if ene == null: return
	
func update_label_coins(coins: int = -1):
	if coins != -1:
		self.coins = coins
	else:
		coins = self.coins
	label_coins.text = str(coins)
	
func update_hearts():
	set_heart_hud(hearts, max_heart)

func set_heart_hud(value: int, max: int):
	
	for c in heart_node.get_children():
		heart_node.remove_child(c)
	
	var heart_model = load("res://Assets/Player/Heats/heart.png")
	var broken_heart = load("res://Assets/Player/Heats/broken_heart.png")
	
	var s_size: Vector2 = get_viewport_rect().size
	var delta_x: float = s_size.x * 0.08
	var delta_y: float = s_size.y * 0.01
	var x_start: float = s_size.x * 0.01
	
	for i in range(max):
		
		var icon: TextureRect = TextureRect.new()
		
		if i >= value:
			icon.texture = broken_heart.duplicate()
		else:
			icon.texture = heart_model.duplicate()
		heart_node.add_child(icon)
		icon.global_position = Vector2(x_start + delta_x * i, delta_y)
		
func upgrade_heart(amount: int):
	max_heart += amount
	
func reset():
	
	set_active(true)
	
	process_mode = Node.PROCESS_MODE_INHERIT
	current_state = PlayerState.MOVING
	weapon_manager.selected.can_toggle = true
	
	can_dash = false   
	
	body.scale = Vector2(1, 1)
	anim.z_index = 0
	
	hearts = max_heart
	update_hearts()
	
	z_index = 0
	is_dead = false
	
func set_active(mode: bool):
	set_process(mode)
	set_physics_process(mode)
	
	var layer = Globals.layers["player"] if mode else 0
	var mask = Globals.layers["enemy"] | Globals.layers["current_wall"] | Globals.layers["ghost"] if mode else 0
	
	body.collision_layer = layer
	body.collision_mask = mask
	
	set_process_input(mode)
	
	if not mode:
		anim.play("idle")
		
func set_collision_ene(mode: bool):
	var mask = Globals.layers["enemy"] | Globals.layers["current_wall"] | Globals.layers["ghost"] if mode else Globals.layers["current_wall"]
	body.collision_mask = mask
	
# problema: ao entrar em algum quarto, ocorre um chance do player nascer dentro 
# de uma parede e nao conseguir se mover
# solução: um raycast vai rotacionar em volta do player, caso o ray achei uma colisao
# ele empurra o player para o lado contrário
func test_wall_stuck():
	raycast2d_node.test_wall_stuck()
	
func update_status(name: String):
	match name:
		"life":
			max_heart = int(attributes[name].get_attr("value"))
			hearts = max_heart
			update_hearts()
		"speed":
			speed = attributes[name].get_attr("value")
		"dash_duration": 
			dash_frames_duration = attributes[name].get_attr("value")
		"dash_coldown": 
			dash_cooldown_frames_duration = attributes[name].get_attr("value")
		"invencible_time": 
			invencible_frames_duration = attributes[name].get_attr("value")

signal _die

signal spend_coins(amount: int)
