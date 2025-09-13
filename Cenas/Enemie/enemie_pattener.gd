extends Character

class_name Enemie

var speed = 200
var damage = 0

var bar: ProgressBar
var body: CharacterBody2D
var player

func _on_light_area():
	return self
	
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	for i in get_children():
		if i is CharacterBody2D:
			body = i
			
		
	for i in body.get_children():
		if i is ProgressBar:
			bar = i			
			
	if bar != null:
		bar.max_value = life
		bar.value = life
			
func _process(delta: float) -> void:
			
	update_bar()
	
	if life <= 0:
		set_process(false)
		visible = false
		
func update_bar():
	if bar == null:
		return
	bar.value = life
	

func _physics_process(delta: float) -> void:
	if player == null:
		return
			
	var direction = (player.global_position - body.global_position).normalized()

	# Aplica movimento
	body.velocity = direction * speed
	body.move_and_slide()
	

	
	
