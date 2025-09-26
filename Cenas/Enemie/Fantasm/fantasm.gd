extends Enemie

class_name Fantasm

var anim: AnimatedSprite2D
var last_position: Vector2
var animation_type: int
var mouse_pos: Vector2
var target_position: Vector2
var is_moving: bool = false


func _ready() -> void:
		
	animation_type = int(randf() * 4) + 1
	
	if animation_type == 4:
		animation_type = 3
				
	for i in body.get_children():
		if i is AnimatedSprite2D:
			if i.name.contains(str(animation_type)):
				anim = i
				break
				
	print(anim.name)
	anim.show()
	
	print(animation_type) 
	
	damage = 5
	speed = 180
	life = 5
	
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
	body.collision_mask = 2
	
	
	
	
	
