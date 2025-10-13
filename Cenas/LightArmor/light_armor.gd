extends Node2D

class_name LightArmor

@export var damage: int = 0
@export var energie = 0
@export var is_active = true
@export var area: Area2D

var enemies_on_light: Dictionary[Enemy, float] = {}

func _ready() -> void:
		#toggle_activate()
	pass
	
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_toggle_armor"):
		print("asd")
		toggle_activate()
	
	#usa a função com a logica da energia
	energie_logic()

func energie_logic():
	
	if energie <= 0:
		if is_active:
			toggle_activate()
		return
				
	if(is_active):
		energie -= 0.1

func toggle_activate():
	pass


	


	
	

	
