extends Enemie

class_name Fantasm

@onready var anim := $CharacterBody2D/AnimatedSprite2D
var last_position: Vector2

func _ready() -> void:
	
	damage = 5
	speed = 100
	life = 5
	size_chase_area = 100
	
	super._ready()
	
	player = get_tree().get_first_node_in_group("player") 

	
func _process(delta: float) -> void:
	animation_logic()
	chase_player()
	super._process(delta)
	
func animation_logic():
	var play := ""
	
	var dir_anim: Vector2
	
	if dir == Vector2.ZERO: dir_anim = last_position
	else: dir_anim = dir
	
	if dir_anim.x > 0:
		play = "right"
	else:
		play = "left"
	
	if dir_anim.y < 0:
		play += "_back"
				
	anim.play(play)
	
func chase_player():
		
	if !is_active or player == null:
		dir = Vector2.ZERO
	else:
		dir = (player.player_body.global_position - body.global_position).normalized()
		last_position = dir

	body.velocity = dir * speed
	body.move_and_slide()	
	
func enable():
	show()
	is_active = true
	body.collision_layer = 2
	body.collision_mask = 0
	
	
	
	
	
