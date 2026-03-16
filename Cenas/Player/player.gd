extends Character
class_name Player

@export var armor: LightArmor

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
@export var armor_manager: ArmorManager
@export var dash_audio: AudioStreamPlayer
@export var raycast2d_node: Node2D

var flick_aux: int = 0

var max_heart: int = 5
var hearts: int = 0

var is_invencible: bool = false
var invencible_duration: float = 1.2
var invencible_duration_bonus: float = 1.0
var invencible_timer: float = 0

var input_vector: Vector2

var speed: float = 100
var speed_bonus: float = 1.0
var dash_speed: float = 600
var dash_duration: float = 0.1
var can_dash = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_cooldown:float = 0.4
var last_direction: Vector2 = Vector2.RIGHT
var dash_dir: Vector2
var dash_target_pos: Vector2

var can_teleport: bool = true

var is_on_knockback = false
var knockback_dir: Vector2
var knockback_force: int
var knockback_time = 0
var knockback_duration = 0.5

var is_in_menu = false
var is_getting_key: bool = false

var wearpowns = [Lantern]

var enemies_touch = {}

var current_ene_defalut: int = 0

var is_dead: bool = false

@export var heart_node: Control
var hearts_control: Array[TextureRect] = []

# new 

enum PlayerState {MOVING, DASHING, KNOCKBACK, MENU, ANIMATION}
var current_state: PlayerState = PlayerState.MOVING

var d: float = 0.0
var t: float = 0.0

func _ready() -> void:
	
	hearts = max_heart
	
		
	update_label_coins()

	_die.connect(
		func():
			if armor.is_active: 
				armor.toggle_activate()
			armor.can_active = false
	)
		
	spend_coins.connect(_spend_coins)
	
	get_window().size_changed.connect(update_hearts)
	update_hearts()
	
func set_armor(armor: LightArmor):
	for child in armor_node.get_children():
		armor_node.remove_child(child)
		
	armor_node.add_child(armor)
	self.armor = armor
		
func _spend_coins(amount: int):
	if amount > coins:
		print("quantidade a ser gasta, execede a quantidade de moedas: Player/spend_coins()")
		return
	coins -= amount
	update_label_coins()
	
func _process(delta: float) -> void:
	if is_in_menu: return
	if coins < 0:
		print("Negativo")
	armor.global_position = body.global_position
	
	
#func _exit_enemie(body):
	##pra pegar o corpo e verificar se é enemie
	#if !(body.get_parent() is Enemy): return
	#var ene = body.get_parent()
	#enemies_touch.erase(ene)
		
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
		dash_cooldown_timer += delta
		if dash_cooldown_timer > dash_cooldown:
			can_dash = true
	if is_invencible:
		invencible_timer += delta
		flick()

		if invencible_timer > invencible_duration:
			is_invencible = false
			invencible_timer = 0.0
			flick_aux = 0
		
		
			
	return
	
	if is_in_menu: return
		
	if is_invencible:
		flick()
	
	if is_on_knockback:			
		body.velocity = knockback_dir * knockback_force
		body.move_and_slide()
		return
#	O knockback vai acabar quando a animação de knockback acabar
	
	dir = get_dir_move()
	dash_state(delta)
	
	body.velocity = dir * (speed * speed_bonus) 

	if is_invencible:
		if invencible_timer >= (invencible_duration * invencible_duration_bonus):
			is_invencible = false
			invencible_timer = 0
			return
		invencible_timer += delta

	body.move_and_slide()

func setup_state(state: PlayerState):
	match state:
		PlayerState.MOVING:
			body.collision_layer = Globals.layers["player"]
			body.collision_mask = Globals.layers["enemy"] | Globals.layers["current_wall"] | Globals.layers["ghost"]
		PlayerState.DASHING:
			if not can_dash: 
				return
			can_dash = false
			dash_timer = 0.0
			dash_dir = last_direction
			body.collision_layer = 0
			body.collision_mask = Globals.layers["current_wall"]
		PlayerState.KNOCKBACK:
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
	
	dash_timer += delta
	
	if dash_timer > dash_duration:
		setup_state(PlayerState.MOVING)
		dash_cooldown_timer = 0.0
	
	return
	
	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		dash_audio.play()
		can_dash = false
		is_dashing = true
		dash_dir = last_direction if dir == Vector2.ZERO else dir
		set_collision_ene(false)
	if is_dashing:
		dash_timer += delta
		if dash_timer >= dash_duration:
			set_collision_ene(true)
			dash_timer = 0
			is_dashing = false
			
		body.velocity = dash_dir * dash_speed
		body.move_and_slide()
		
	if not can_dash and not is_dashing:
		dash_cooldown_timer += delta
		if dash_cooldown_timer >= dash_cooldown:
			can_dash = true
			dash_cooldown_timer = 0
			
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
		
	#if is_on_knockback or is_getting_key or is_dead: return
	
	#var play = ""
	
	#var is_moving = dir != Vector2.ZERO
	#
	#if armor.is_active:
		#dir = armor.armor_dir
		#
	#if not is_moving:
		#play = "idle"
		#if not armor.is_active:
			#dir = last_direction
	#else:
		#play = "walk"
		#
	#play += "_back" if dir.y < 0 else ""
	#
		#
	#anim.flip_h = dir.x > 0
	#anim.play(play)

func knockback_animation(dir: Vector2):
	
	anim.play("knockback")
	anim.flip_h = dir.x > 0
	
	await anim.animation_finished
	
	last_direction = -dir
	last_direction.y = 1
	is_on_knockback = false
	
func get_key_animation(key: Key):
	
	key.is_move = false
	
	if armor.is_active:
		armor.toggle_activate()
	
	set_process(false)
	set_physics_process(false)
		
	var tween = create_tween()
	
	is_getting_key = true
	anim.play("get_item")
	
	var final_pos = body.global_position
	final_pos.y -= 20
	
	tween.tween_property(key, "global_position", final_pos, 2)
	
	return tween.finished

func _unlocked_doors():
	pass
	
func take_damage(damage: int):
	
	if is_invencible or current_state == PlayerState.DASHING: return
	is_invencible = true
	
	setup_state(PlayerState.KNOCKBACK)
	
	if not can_die: return
	hearts -= damage;
	update_hearts()
	
	if hearts <= 0 and Globals.can_player_die:
		die()
	
func die():
	
	if is_dead: return
	
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
	
func update_label_coins():
	label_coins.text = str(coins)
	
func update_hearts():
	set_heart_hud(hearts, max_heart)
	
	#for child in heart_conteiner.get_children():
		#if is_instance_valid(child):
			#heart_conteiner.remove_child(child)
			#child.queue_free()
	#if hearts == max_heart:
		#var text = TextureRect.new()
		#text.texture = heart_model
		#for i in range(max_heart):
			#heart_conteiner.add_child(text.duplicate())
		#return
	#for i in range(max_heart):
		#var text = TextureRect.new()
		#if i <= hearts - 1:
			#text.texture = heart_model
		#else:
			#text.texture = broken_heart
		#heart_conteiner.add_child(text)
		
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
	
	#armor.set_process(true)
	#armor.set_physics_process(true)
	
	process_mode = Node.PROCESS_MODE_INHERIT
	current_state = PlayerState.MOVING
	
	can_dash = false   
	armor.can_active = true
	
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
		if armor.is_active:
			armor.toggle_activate()
		anim.play("idle")
		
	armor.can_active = mode

func set_collision_ene(mode: bool):
	var mask = Globals.layers["enemy"] | Globals.layers["current_wall"] | Globals.layers["ghost"] if mode else Globals.layers["current_wall"]
	body.collision_mask = mask
	
# problema: ao entrar em algum quarto, ocorre um chance do player nascer dentro 
# de uma parede e nao conseguir se mover
# solução: um raycast vai rotacionar em volta do player, caso o ray achei uma colisao
# ele empurra o player para o lado contrário
func test_wall_stuck():
	raycast2d_node.test_wall_stuck()
	
signal _die

signal spend_coins(amount: int)
