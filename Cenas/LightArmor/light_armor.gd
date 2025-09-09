extends Node2D

class_name LightArmor

var damage: int = 10
var energie = 5
var activate = false

func energie_logic():
	
	if(energie <= -1):
		set_activate(false)
	
	if(activate):
		energie -= 0.1
		print("energie: ", energie)


func set_activate(mode: bool):
	
	activate = mode
		
	for i in get_children():
		i.set_process(activate)
		i.visible = activate


	
	

	
