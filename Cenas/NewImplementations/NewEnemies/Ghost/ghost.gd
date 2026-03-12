extends _Enemy

class_name _Ghost

var animation_type: int

@export var attack_animated: AnimatedSprite2D
@export var slash_attack_area: Area2D

func _ready() -> void:
	animation_type = randi_range(1, 4)
	
	slash_attack_area.collision_layer = Globals.layers["enemy"]
	slash_attack_area.collision_mask = Globals.layers["player"]
	
	collision_layer = Globals.layers["enemy"]
	collision_mask = Globals.layers["player"]
	
	life_attr = SimpleAttribute.new(10, 2, 10, 1)
	speed_attr = SimpleAttribute.new(120.0, 220.0, 10, 1)
	damage_attr = SimpleAttribute.new(3, 1, 10, 1)
	
	setup()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func waiting_state(delta: float):
	if t > d:
		setup_state(EnemyState.CHASING)
		return
	t += delta
	
func chase_state(delta: float):
	if dist_player() < 15.0:
		setup_state(EnemyState.ATTACKING)
		return
	
	velocity = dir_player() * speed
	move_and_slide()
		
func attacking_state(delta: float):
	if t > d: 
		play_attack_animation()		
		for body in slash_attack_area.get_overlapping_bodies():
			if body.get_parent() is Player:
				damage_player()
				break
		return
	t += delta
		
func animation_logic():
	if life <= 0: return
	var dir: Vector2 = dir_player()
	var play: String = "type"
	if dir.y < 0:
		play += "_back"
		if animation_type % 2 == 0:
			play += "_bold"
	else:
		play += str(animation_type)
	animated_sprite.flip_h = dir.x > 0
	animated_sprite.play(play)
	
func play_attack_animation():
		
	if attack_animated.visible: return

	attack_animated.visible = true
	
	var dir: Vector2 = dir_player()
	
	attack_animated.rotation = 0.0
	attack_animated.rotation = dir.angle()

	attack_animated.global_position += dir * 10
		
	attack_animated.play("attack")
	setup_state(EnemyState.WAITING)

	await attack_animated.animation_finished
	
	attack_animated.visible = false
	attack_animated.global_position = global_position

func setup_state(state: EnemyState):
	match state:
		EnemyState.WAITING:
			t = 0.0
			d = 1.0
		EnemyState.ATTACKING:
			t = 0.0
			d = 0.2
	current_state = state
	
	
