extends Character
class_name Player

var armor: LightArmor
var armorEnergie

var speed: float = 200
var dash_speed: float = 600
var dash_time: float = 0.2
var dash_cooldown: float = 0.5

var last_direction: Vector2 = Vector2.RIGHT
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

var can_teleport = true

@onready var playerBody := $CharacterBody2D as CharacterBody2D

var enemies_touch = {}

func _ready() -> void:
	
	var bodyArea = playerBody.get_node("Area2D") as Area2D
	
	bodyArea.body_entered.connect(_touch_enemie)
	bodyArea.body_exited.connect(_exit_enemie)
	
	armor = preload("res://Cenas/LightArmor/Lantern/lantern.tscn").instantiate()
	armor.player = self
	add_child(armor)
	
func _process(delta: float) -> void:
	takeDamagePlayerLogic(delta)
	
func _touch_enemie(body):
	var ene = body.get_parent()
	if ene != null and ene is Enemie:
		enemies_touch[ene] = 0.0

#para quando o inimigo para de encostar no player
func _exit_enemie(body):
	#pra pegar o corpo e verificar se é enemie
	var ene = body.get_parent()
	if ene != null and ene is Enemie:
		enemies_touch.erase(ene)
		ene.atack_player = false
		
func takeDamagePlayerLogic(delta):
	for ene in enemies_touch.keys():
		
		if !ene.enemie_active: return
	#Enquanto o inimigo encosta no player, ele nao se mexe
		(ene as Enemie).atack_player = true
		#Vai contando quanto tempo o inimigo esta tocando no playwr
		enemies_touch[ene] += delta
		#Se foi maior que meio segungo
		if enemies_touch[ene] >= 0.1:
			#O tempo volta pra zero
			enemies_touch[ene] = 0
			#Vai tirar a vida do player
			life -= ene.damage
			
func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO

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
		playerBody.velocity = last_direction * dash_speed

	# Atualizar dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
			playerBody.velocity = Vector2.ZERO
	else:
		playerBody.velocity = input_vector * speed

	playerBody.move_and_slide()  
	
