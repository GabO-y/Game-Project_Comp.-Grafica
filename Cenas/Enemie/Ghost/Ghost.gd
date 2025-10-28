extends Enemy

class_name Ghost

var animation_type: int
var mouse_pos: Vector2

# Variaveis referentes ao ataque
var time_attack = 0.5;
var timer_attack = 0
var last_dir_player: Vector2
var is_continue_toward := false

var is_dashing := false
var dash_dir: Vector2
var dash_duration := 0.4
var dash_timer = 0
var dash_speed := 200
var is_prepare_attack = false

var wait_timer = 0
var wait_duration = 1.2

var special_attack = ""

enum State {
	CHASE,
	PREPARE_ATTACKING,
	DASHING
}

var current_state: State

func _ready() -> void:
		
	animation_type = int(randf() * 4) + 1
	
	if animation_type == 4:
		animation_type = 3
							
	anim.show()
	
	life = 5
		
	super._ready()
	
	player = get_tree().get_first_node_in_group("player") 
	
	body.collision_layer = Globals.layers["enemy"]
	body.collision_mask = Globals.layers["wall_current_room"]

func _process(delta: float) -> void:
	
	if is_stop: return
	
	var dist = body.global_position.distance_to(Globals.player_pos)
			
	if not special_attack.is_empty():
		match special_attack:
			"ghosts_run":
				ghosts_run_move()
		return
				
	match current_state:
		State.CHASE:
			chase_player(dist)
		State.PREPARE_ATTACKING:
			prepare_attack(delta)
		State.DASHING:
			dash(delta)
			
	animation_logic()
		
	super._process(delta)

func prepare_attack(delta):
	
	wait_timer += delta

	if wait_timer >= wait_duration:
		current_state = State.DASHING
		is_dashing = true
		wait_timer = 0
		dash_dir = body.global_position.direction_to(Globals.player_pos)
		last_dir = dash_dir
		body.collision_mask = Globals.layers["wall_current_room"]
				
func dash(delta):
		
	body.velocity = dash_dir * dash_speed
	body.move_and_slide()
		
	dash_timer += delta
		
	if dash_timer >= dash_duration:
		dash_timer = 0
		current_state = State.CHASE
		is_dashing = false		
		body.collision_mask = Globals.layers["ghost"]
	
func animation_logic():
	
	if is_dead: return
	
	var play = "type_" + str(animation_type)
	if dir.y < 0:
		play = "back" + str("" if(
			animation_type % 2 != 0
		) else "_bald") 
	
	anim.flip_h = dir.x > 0
	anim.play(play)
	
func set_active(mode: bool):
	super.set_active(mode)
	
	var layer = Globals.layers["ghost"] if mode else 0
	
	body.collision_layer = layer
	body.collision_mask = layer
	
func chase_player(dist):
	
	if (dist < 40):
		current_state = State.PREPARE_ATTACKING
		return
	
	if is_attacking: return
	
	dir = Globals.dir_to(body.global_position, Globals.player_pos)

	body.velocity = dir * speed
	body.move_and_slide()
	
func enable():
	show()
	is_active = true
	refrash()

func _player_enter_hit(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if player == null: return
	
	player.take_knockback(dir, 10)
	player.take_damage(damage)
	
func refrash():
	body.collision_layer = Globals.layers["enemy"]
	body.collision_mask = Globals.layers["wall_current_room"]
	
func ghosts_run_move():
	
	var ene_pos = body.global_position
	var pla_pos = Globals.player_pos
	
	var dist = ene_pos.distance_to(pla_pos)
	dir = ene_pos.direction_to(pla_pos)
	
	if dist <= 40 or is_continue_toward:
		dir = last_dir_player
		is_continue_toward = true
	else:
		last_dir_player = dir
	
	body.velocity = dir * speed
	body.move_and_slide()

func take_damage(damage: int):
	super.take_damage(damage)
	drop_damage_label(damage)

func drop_damage_label(damage: int):
	var label := Label.new()
	label.text = str(damage)
	label.modulate = Color.RED
	
	label.label_settings = LabelSettings.new()
	label.label_settings.font_size = 8
	
	call_deferred("add_child", label)
	
	var curve = Globals.create_curve_drop(
		body.global_position,
		[true, false].pick_random(),
		1.1,
		1
	)
	
	var tween = create_tween()
	tween.tween_method(_drop_damage_animation.bind(curve, label), 0.0, 1.0, 3)
	
	tween.tween_callback(label.queue_free)
	
func _drop_damage_animation(t: float, curve: Array[Vector2], label: Label):
	if t == 1: return
	var p = curve.get(curve.size() * t)
	label.global_position = p
	
