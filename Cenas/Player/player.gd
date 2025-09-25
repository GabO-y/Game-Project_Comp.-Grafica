extends Character
class_name Player

@export var armor: LightArmor
@export var armor_energie: int

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

@onready var player_body := $CharacterBody2D as CharacterBody2D
@onready var anim := $CharacterBody2D/AnimatedSprite2D

var enemies_touch = {}

func _ready() -> void:
		
	var hit_area = $CharacterBody2D/HitArea as Area2D
	
	hit_area.body_entered.connect(_touch_enemie)
	hit_area.body_exited.connect(_exit_enemie)
	
	armor = preload("res://Cenas/LightArmor/Lantern/Lantern.tscn").instantiate()
	armor.player = self
	add_child(armor)
	

func _process(delta: float) -> void:
	animation_logic()
	takeDamagePlayerLogic(delta)
	
	if life <= 0:
		player_die.emit(self)
	
func _touch_enemie(body):
	if !(body.get_parent() is Enemie): return
	enemies_touch[body.get_parent()] = 0.0

#para quando o inimigo para de encostar no player
func _exit_enemie(body):
	#pra pegar o corpo e verificar se é enemie
	if !(body.get_parent() is Enemie): return

	var ene = body.get_parent()
	
	enemies_touch.erase(ene)
	ene.atack_player = false
		
func takeDamagePlayerLogic(delta):

	for enemie in enemies_touch.keys():
		
		enemie = enemie as Enemie
		
		if !enemie.is_active: return
		#Enquanto o inimigo encosta no player, ele nao se mexe
		enemie.atack_player = true
		#Vai contando quanto tempo o inimigo esta tocando no playwr
		enemies_touch[enemie] += delta
		#Se foi maior que meio segungo
		if enemies_touch[enemie] >= 0.1:
			#O tempo volta pra zero
			enemies_touch[enemie] = 0
			#Vai tirar a vida do player
			life -= enemie.damage
			
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
	
signal player_die(player: Player)
