extends Node2D

class_name LightArmor

var damage: int = 10
var energie = 50

@export var is_active = true
@export var area: Area2D

var enemies_on_light: Dictionary[Enemy, float] = {}

func _ready() -> void:
							
	#Para todas as areas pegas, ele adiciona o sinal que verifica se um inimigo esta na luz
	area.body_entered.connect(_init_time_hit)
	area.body_exited.connect(_reset_time_hit)
		
	toggle_active.connect(_on_toggle_activate)
	
	_on_toggle_activate()
		
func _process(delta: float) -> void:
			
	for body in enemies_on_light.keys():
		if body == null:
			continue
	
		# vai incrementando o tempo conforme ele fica na area
		enemies_on_light[body] += delta
		# se der 1 segundos, ele zera o tempo e da o dano
		if(enemies_on_light[body] >= 1.0):
			body.take_damage(damage) 
			enemies_on_light[body] = 0.0
		
	#usa a função com a logica da energia
	energie_logic()

func energie_logic():
	
	if energie <= 0:
		if is_active:
			_on_toggle_activate()
		return
				
	if(is_active):
		energie -= 0.1

					
func _init_time_hit(ene: CharacterBody2D):		
		
	var parent = ene.get_parent() as Enemy
	
	if parent == null or parent is not Enemy:
		return	
		
	enemies_on_light[parent] = 0.0
	
#se ele sair, remove do verificador
func _reset_time_hit(ene: Node):
	var parent = ene.get_parent()
	
	if !(parent is Enemy):
		return
	enemies_on_light.erase(ene.get_parent())
	
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
	


	
	

	
