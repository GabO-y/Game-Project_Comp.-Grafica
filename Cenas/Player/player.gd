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
@export var hud: CanvasLayer
@export var label_coins: Label

var original_modulate = self.modulate
var modulate_timer = 0
var white_time := true
var is_flicking = false

var hearts = 3
var is_invencible = false
var invencible_duration = 1.2
var invencible_timer = 0

var input_vector

var speed: float = 100
var dash_speed: float = 600
var dash_duration = 0.1
var can_dash = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_cooldown = 0.4
var last_direction: Vector2 = Vector2.RIGHT
var dash_dir: Vector2

var can_teleport = true
var last_direction_right

var is_on_knockback = false
var knockback_dir: Vector2
var knockback_force: int
var knockback_time = 0
var knockback_duration = 0.5

var is_in_menu = false
var is_getting_key: bool = false

var wearpowns = [Lantern]

var power_ups = {}

var enemies_touch = {}

func _ready() -> void:
			
	hit_area.body_exited.connect(_exit_enemie)
	
	armor.toggle_activate()
	
	body.collision_mask |= Globals.layers["wall_current_room"]
	
	update_label_coins()
	
func _process(delta: float) -> void:
	
	$CharacterBody2D/Label.text = str(hearts)
	
	if is_in_menu: return
		
	animation_logic()
	
	armor.global_position = body.global_position
	
	if hearts <= 0 and can_die:
		player_die.emit(self)
		
func _exit_enemie(body):
	#pra pegar o corpo e verificar se é enemie
	if !(body.get_parent() is Enemy): return
	var ene = body.get_parent()
	enemies_touch.erase(ene)
		
func _physics_process(delta: float) -> void:
	
	if is_in_menu: return
		
	if is_invencible:
		flick_invensible()
	
	if is_on_knockback:			
		body.velocity = knockback_dir * knockback_force
		body.move_and_slide()
		return
#		O knockback vai acabar quando a animação de knockback acabar
	
	dir = move_logic()
	dash_logic(delta)

	body.velocity = dir * speed

	if is_invencible:
		if invencible_timer >= invencible_duration:
			is_invencible = false
			invencible_timer = 0
			return
		invencible_timer += delta

	body.move_and_slide()  

func dash_logic(delta):
	
	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		can_dash = false
		is_dashing = true
		dash_dir = last_direction if dir == Vector2.ZERO else dir
		
	if is_dashing:
		dash_timer += delta
		if dash_timer >= dash_duration:
			dash_timer = 0
			is_dashing = false
			
		body.velocity = dash_dir * dash_speed
		body.move_and_slide()
		
	if not can_dash and not is_dashing:
		dash_cooldown_timer += delta
		if dash_cooldown_timer >= dash_cooldown:
			can_dash = true
			dash_cooldown_timer = 0
			
func move_logic():
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
	
	if is_on_knockback or is_getting_key: return
	
	var play = ""
	
	if dir == Vector2.ZERO:
		play = "idle"
		dir = last_direction
	else:
		play = "walk"
		
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
	
	if is_invencible: return
	is_invencible = true
	
	hearts -= damage;
	
func flick_invensible():
		
	if is_flicking: return
	
	if white_time:
		to_white_color()
	else:
		to_original_color()
		

func to_white_color():
		
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color(2, 2, 2), 0.1)
	is_flicking = true
		
	await tween.finished
	
	white_time = false
	is_flicking = false
	
	if not is_invencible:
		anim.modulate = Color.WHITE
	
func to_original_color():
		
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color.WHITE, 0.1)
		
	is_flicking = true
	await tween.finished
		
	white_time = true
	is_flicking = false
	
	if not is_invencible:
		anim.modulate = Color.WHITE
	
func take_knockback(direction: Vector2, force: int):
	
	if is_invencible: return
		
	is_on_knockback = true
	knockback_dir = direction
	knockback_force = force
	
	knockback_animation(direction)

func _on_hit_area_body_entered(body: Node2D) -> void:
	var ene = body.get_parent() as Enemy
	if ene == null: return
	if hit_kill:
		ene.take_damage(ene.life)

func update_label_coins():
	label_coins.text = str(coins)

signal player_die(player: Player)
