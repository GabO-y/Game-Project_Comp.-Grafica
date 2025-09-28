extends Character
class_name Player

@export var armor: LightArmor
@export var armor_energie: int
var items: Array[Item]

var input_vector

var speed: float = 140
var dash_speed: float = 600
var dash_time: float = 0.2
var dash_cooldown: float = 0.5

var last_direction: Vector2 = Vector2.RIGHT
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

var can_teleport = true
var last_direction_right

@export var player_body: CharacterBody2D
@export var anim: AnimatedSprite2D
@export var hit_area: Area2D

var enemies_touch = {}

func _ready() -> void:
	
	items.append(Key.generate_key("SafeRoom,Hallway1"))
			
	hit_area.area_entered.connect(_on_key_entered)
	hit_area.body_entered.connect(_on_enemy_entered)
	hit_area.body_exited.connect(_exit_enemie)
	
	armor = preload("res://Cenas/LightArmor/Lantern/Lantern.tscn").instantiate()
	armor.player = self
	add_child(armor)
	
	for i in items:
		print(i.name)
	

func _process(delta: float) -> void:
	animation_logic()
	takeDamagePlayerLogic(delta)
	
	#if life <= 0:
		#player_die.emit(self)
	
func _on_enemy_entered(body):
	if body.get_parent() is not Enemy: return
	enemies_touch[body.get_parent()] = 0.0
	
func _on_key_entered(area):
	
	if Globals.have_enemy_live(): return

	if  !Globals.current_room.finish: return

	
	var key = area.get_parent()
	
	print(key)
	
	if key is not Key: return
		
	get_key_animation(key)

#para quando o inimigo para de encostar no player
func _exit_enemie(body):
	#pra pegar o corpo e verificar se é enemie
	if !(body.get_parent() is Enemy): return

	var ene = body.get_parent()
	
	enemies_touch.erase(ene)
	ene.atack_player = false
		
func takeDamagePlayerLogic(delta):

	for enemy in enemies_touch.keys():
		
		enemy = enemy as Enemy
		
		if !enemy.is_active: return
		#Enquanto o inimigo encosta no player, ele nao se mexe
		enemy.atack_player = true
		#Vai contando quanto tempo o inimigo esta tocando no playwr
		enemies_touch[enemy] += delta
		#Se foi maior que meio segungo
		if enemies_touch[enemy] >= 0.1:
			#O tempo volta pra zero
			enemies_touch[enemy] = 0
			#Vai tirar a vida do player
			life -= enemy.damage
			
func _physics_process(delta: float) -> void:
	
	input_vector = Vector2.ZERO
	# Joystick
	input_vector.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	input_vector.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)

	# Teclado
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1

	# Normalizar e atualizar last_direction
	if input_vector.length() < 0.2:
		input_vector = Vector2.ZERO
	else:
		input_vector = input_vector.normalized()
		last_direction = input_vector

	# Atualizar cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Iniciar dash
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = dash_time
		player_body.velocity = last_direction * dash_speed

	# Atualizar dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
			player_body.velocity = Vector2.ZERO
	else:
		player_body.velocity = input_vector * speed

	player_body.move_and_slide()  
	
func animation_logic():
		
	var right_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) # mesmo que 2
	var right_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) # mesmo que 3

# Cria o vetor de direção
	var dir = Vector2(right_x, right_y)
	var idle = false

# Se quiser normalizar (pra usar só direção, ignorando intensidade)
	if dir.length() > 0.2: # deadzone (evita drift)
		dir = dir.normalized()
		last_direction_right = dir
	elif input_vector.length() != 0:
		dir = Vector2(input_vector.x, input_vector.y)
	else:
		dir = last_direction
		idle = true
	
		
	var play = ""
	
	if dir.length() > 0.2:
		if dir.x > 0:
			play += "right_"
		else:
			play += "left_"
			
		if dir.y < 0:
			play += "back_"
		
		if idle:
			play += "idle"
		else:
			play += "walk" 
			
	anim.play(play)
	
#func get_key_animation(key: Key):
	#
	#anim.sprite_frames.set_animation_loop("get_item", false)
	#anim.play("get_item")
	#
	#anim.process_mode = Node.PROCESS_MODE_ALWAYS
	#get_tree().paused = true
	#
	#var x = key.position.x
	#var y = key.position.y
	#
	#while x != player_body.global_position.x and y != player_body.global_position.y:
		#x += key.global_position.direction_to(player_body.global_position).x * 0.1
		#y += key.global_position.direction_to(player_body.global_position).y * 0.1
#
	#await get_tree().create_timer(3).timeout	
	#
	#anim.process_mode = PROCESS_MODE_INHERIT
	#get_tree().paused = false

func get_key_animation(key: Key):
	
	armor.set_activate(false)
	get_tree().paused = true
	
	anim.process_mode = Node.PROCESS_MODE_ALWAYS
	key.process_mode = Node.PROCESS_MODE_ALWAYS
	
	anim.sprite_frames.set_animation_loop("get_item", false)
	anim.play("get_item")
	
	var duration = 0.2 
	var elapsed = 0.0
	var start_pos = key.global_position
	var end_pos = player_body.global_position
	end_pos.y -= 15
	
	while elapsed < duration:
		var progress = elapsed / duration
		
		key.global_position = start_pos.lerp(end_pos, progress)
		
		elapsed += get_physics_process_delta_time()
		
		await get_tree().process_frame
	
	key.global_position = end_pos
	key.scale = Vector2(1.5, 1.5)  
	key.label.visible = true
	
	while anim.is_playing():
		await get_tree().process_frame
		
	await key.play_scale_key()
	
	Globals.is_get_animation = true
	
signal player_die(player: Player)
