extends CharacterBody2D

var armor: LightArmor
var armorEnergie

var speed: float = 200
var dash_speed: float = 600
var dash_time: float = 0.2
var dash_cooldown: float = 0.5
var stamina = 50
var stamina_per_dash = 5

var last_direction: Vector2 = Vector2.RIGHT
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

func _ready() -> void:
	armor = preload("res://Cenas/LightArmor/Lighter/Lighter.tscn").instantiate()
	add_child(armor)

func _physics_process(delta: float) -> void:
	armor.global_position = global_position
	
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
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0 and stamina > 0:
		stamina -= stamina_per_dash
		is_dashing = true
		dash_timer = dash_time
		velocity = last_direction * dash_speed
		print(stamina)

	# Atualizar dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
			velocity = Vector2.ZERO
	else:
		velocity = input_vector * speed

	move_and_slide()  
	
signal hit(body: Enemie)
