extends Node2D

class_name LightArmor

@export var damage: int = 0
@export var energie = 0
@export var is_active = true
@export var area: Area2D

var enemies_on_light: Dictionary[Enemy, float] = {}

func _ready() -> void:
	toggle_active.connect(_on_toggle_activate)
	_on_toggle_activate()
		
func _process(delta: float) -> void:
	#usa a função com a logica da energia
	energie_logic()

func energie_logic():
	
	if energie <= 0:
		if is_active:
			_on_toggle_activate()
		return
				
	if(is_active):
		energie -= 0.1

func _on_toggle_activate():
	is_active = !is_active
		
	if is_active:
		area.show()
		area.collision_layer = 1
		area.collision_mask = (1 << 0) | (1 << 1)
	else:
		area.hide()
		area.collision_layer = 0
		area.collision_mask = 0

signal toggle_active
	


	
	

	
