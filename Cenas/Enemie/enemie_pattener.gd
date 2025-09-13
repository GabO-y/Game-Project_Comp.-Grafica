extends Character

class_name Enemie

var speed = 200

var bar: ProgressBar
var body: CharacterBody2D

func _on_light_area():
	return self
	
func _ready() -> void:
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
	
	
