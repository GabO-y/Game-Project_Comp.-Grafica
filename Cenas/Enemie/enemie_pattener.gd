extends Character

class_name Enemie

var body: CharacterBody2D

func _on_light_area():
	return self
	
func _ready() -> void:
	for i in get_children():
		if i is CharacterBody2D:
			body = i
	
