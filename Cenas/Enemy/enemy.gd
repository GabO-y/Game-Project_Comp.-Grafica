extends Character

class_name Enemy

@export var level: int = 1

var speed: float 
var heart: int 
var damage: int 

var wait_frames_count: int = 0
var wait_frames_duration: int

var take_damage_frames_count: int = 0
var take_damage_coldown_frames: int 

var attributes: Dictionary = {}

@export var body: CharacterBody2D 
@export var anim: AnimatedSprite2D

var current_state: EnemyState = EnemyState.CHASING
# variaveis genericas para servir como timer e duration

var t: float = 0.0
var d: float = 0.0

func _ready() -> void:
	body.collision_layer = Globals.layers["enemy"]
	body.collision_mask = Globals.layers["player"] | Globals.layers["weapon"] | Globals.layers["current_wall"] 
	setup_status()
	
func _physics_process(delta: float) -> void:
	if Globals.player.hearts <= 0:
		setup_state(EnemyState.WAITING)
	match current_state:
		EnemyState.WAITING:
			waiting_state(delta)
		EnemyState.CHASING:
			chasing_state(delta)
		EnemyState.DASHING:
			dashing_state(delta)
		EnemyState.ATTACKING:
			attacking_state(delta)
		EnemyState.STUNED:
			stuned_state(delta)
		EnemyState.CUSTOM:
			custom_state(delta)
			
func chasing_state(delta: float):
	pass

func waiting_state(delta: float):
	pass
	
func dashing_state(delta: float):
	pass
	
func attacking_state(delta: float):
	pass
	
func stuned_state(delta: float): 
	pass
	
func custom_state(delta: float):
	pass
	
func setup_custom_state(custom_idx: int):
	pass
	
func setup_state(state: EnemyState):
	pass
	
func take_damage(damage: float):
	heart -= damage
	drop_damage_label(damage)
	Globals.audio_manager.play("hit", "Enemies")
	if heart <= 0:
		die()
	else:
		change_color_damage()

func die():

	set_physics_process(false)
	set_process(false)
	
	body.collision_layer = 0
	body.collision_mask = 0
	
	if not self is Boss:
		anim.play("die")
	
	await anim.animation_finished

	visible = false
	enemy_die.emit(self)

func change_color_damage():
	var tween: Tween = create_tween()
	tween.tween_method(
	func(t: float):
		modulate = Color.RED + (Color.WHITE - Color.RED) * t
		,0.0, 1.0, 1.0
	)
	tween.finished.connect(
		func():
			modulate = Color.WHITE
	)
func drop_damage_label(damage: int):
	var label := Label.new()
	label.text = str("-", damage)
	label.modulate = Color.RED
	
	label.label_settings = LabelSettings.new()
	label.label_settings.font_size = 8
	
	call_deferred("add_child", label)
	
	var p0 = body.global_position
	var p1 = p0
	var p2 = p0
	
	p1.y -= 20
	p2.y -= 15
	
	var curve: MyCurve = MyCurve.new(p0, p1, p2)
	
	var tween = create_tween()
	tween.tween_method(_drop_damage_animation.bind(curve, label), 0.0, 1.0, 2)
	
	tween.tween_callback(label.queue_free)
	
func _drop_damage_animation(t: float, curve: MyCurve, label: Label):
	var p = curve.get_point(t)
	label.global_position = p
	
func dir_to_player() -> Vector2:
	return body.global_position.direction_to(Globals.player_pos()).normalized()
	
func dist_to_player() -> float: 
	return body.global_position.distance_to(Globals.player_pos())
	
func chase_player(dist_limit: float = 0.0, speed_multplier: float = 1.0) -> bool:
	if dist_to_player() <= dist_limit:
		return true
	body.velocity = dir_to_player() * speed * speed_multplier
	body.move_and_slide()
	return false
	
func setup_status():
	attributes = { 
		"damage": SimpleAttribute.new(),
		"heart": SimpleAttribute.new(),
		"speed": SimpleAttribute.new(),
		"take_damage": SimpleAttribute.new()
	}
	update_all_status()
	
func update_status(name: String):
	var attr: SimpleAttribute = attributes[name]
	match name:
		"damage": damage = attr.get_value(level)
		"heart": heart = attr.get_value(level)
		"speed": speed = attr.get_value(level)
		"wait_frames": wait_frames_duration = attr.get_value(level)
		"take_damage": take_damage_coldown_frames = attr.get_value(level)
	return attr
	
func update_all_status():
	for attr in attributes.keys():
		update_status(attr)
		
signal enemy_die(ene: Enemy)

enum EnemyState {WAITING, CHASING, DASHING, ATTACKING, STUNED, CUSTOM}
