extends Enemy

class_name Fantasm

var animation_type: int
var mouse_pos: Vector2


func _ready() -> void:
		
	animation_type = int(randf() * 4) + 1
	
	if animation_type == 4:
		animation_type = 3
							
	anim.show()
	
	damage = 5
	life = 5
		
	super._ready()
	
	player = get_tree().get_first_node_in_group("player") 

func _process(delta: float) -> void:
	animation_logic()
	chase_player()
	super._process(delta)
	
func animation_logic():
	
	if atack_player: return
	
	var play := ""
	
	var dir_anim: Vector2

	if dir == Vector2.ZERO: 
		dir_anim = last_position
	else: 
		dir_anim = dir
	
	if dir_anim.x > 0:
		play = "right"
	else:
		play = "left"
	
	if dir_anim.y < 0:
		play += "_back"
		
	if play.contains("back"):
		if (animation_type == 2 || animation_type == 4) and play.contains("back"):
			play += "_bald"
	else:
		play += str(animation_type)
					
	anim.play(play)
	
func chase_player():
	
	var ene_pos = body.global_position
	var pla_pos = player.player_body.global_position
	
	if !is_active or player == null or ene_pos.distance_to(pla_pos) < 15:
		dir = Vector2.ZERO
	else:
		dir = (pla_pos - ene_pos).normalized()
		last_position = dir
		
	body.velocity = dir * speed
	
	body.move_and_slide()
	
func enable():
	show()
	is_active = true
	body.collision_layer = 2
	body.collision_mask = 2
	
func death_animation():
		
	var play = "die_right" if last_position.x > 0 else "die_left"
	
	anim.sprite_frames.set_animation_loop(play, false)
	anim.play(play)

	return anim.animation_finished
		
	
