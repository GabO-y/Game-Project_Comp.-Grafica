extends Enemy

class_name Fantasm

var last_position: Vector2
var animation_type: int
var mouse_pos: Vector2

func _ready() -> void:
		
	animation_type = int(randf() * 4) + 1
	
	if animation_type == 4:
		animation_type = 3
				
	for i in body.get_children():
		if i is AnimatedSprite2D:
			if i.name.contains(str(animation_type)):
				anim = i
				break
				
	anim.show()
		
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
				
	anim.play(play)
	
func chase_player():
	
	var ene_pos = body.global_position
	var pla_pos = player.player_body.global_position
	
		
	if !is_active or player == null or ene_pos.distance_to(pla_pos) < 3:
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
	
func die():
	
	print("dropou:")
	for i in drop:
		print("\t", i)
		
	if !is_active: return

	anim.visible = false
	disable()

	var die := $CharacterBody2D/Animated1 as AnimatedSprite2D
	die.visible = true
	
	if last_position.x > 0:
		die.play("die_right")
		die.sprite_frames.set_animation_loop("die_right", false)
	else:
		die.play("die_left")
		die.sprite_frames.set_animation_loop("die_left", false)
		
	await die.animation_finished
	die.visible = false

	die_alert.emit(drop, body.global_position)

		

	
	
	
	
