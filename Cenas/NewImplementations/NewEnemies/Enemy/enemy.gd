extends CharacterBody2D

class_name _Enemy

@export var animated_sprite: AnimatedSprite2D

var life: int
var speed: float
var damage: int

var life_attr: SimpleAttribute = SimpleAttribute.new()
var speed_attr: SimpleAttribute = SimpleAttribute.new()
var damage_attr: SimpleAttribute = SimpleAttribute.new()

var level: int = 1

var current_state: EnemyState = EnemyState.WAITING

var t: float = 0.0
var d: float = 0.0

func _physics_process(delta: float) -> void:
	if life <= 0: return
	animation_logic()
	match current_state:
		EnemyState.WAITING:
			waiting_state(delta)
		EnemyState.CHASING:
			chase_state(delta)
		EnemyState.ATTACKING:
			attacking_state(delta)
		EnemyState.DASHING:
			dashing_state(delta)
			
func waiting_state(delta: float):
	pass
	
func chase_state(delta: float):
	pass
	
func attacking_state(delta: float):
	pass
	
func dashing_state(delta: float):
	pass
	
func setup_state(state: EnemyState):
	pass
	
func animation_logic():
	pass
	
func dir_player() -> Vector2:
	return global_position.direction_to(Globals.player.body.global_position)

func dist_player() -> float:
	return global_position.distance_to(Globals.player.body.global_position)
	
func take_damage(d: int):
	life -= d

	if life <= 0: 
		
		animated_sprite.play("die")
		
		await animated_sprite.animation_finished
		get_parent().remove_child(self)
		queue_free()
		return

	var tween: Tween = create_tween()
	var original_color = modulate
	tween.tween_method(
		func(d):
		modulate = Color(d, 0, 0)
		, 0.0, 1.0, 0.1
	)
	await tween.finished
	modulate = original_color
	
	
func damage_player():
	Globals.player.take_damage(damage)
	
func setup():
	life = int(life_attr.get_value(level))
	damage = int(damage_attr.get_value(level))
	speed = speed_attr.get_value(level)

enum EnemyState {WAITING, CHASING, ATTACKING, DASHING}

signal enemy_die(ene: _Enemy)
