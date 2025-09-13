extends Node2D

class_name LightArmor

var damage: int = 10
var energie = 50
var activate = false
var area: Area2D

var enemies_on_light:Dictionary[Enemie, float] = {}
var readyTime = false

func _ready() -> void:
	
	#Pega as areas 2d que estao nas instancias armas e adiciona num array
	for i in get_children():
		if i is Area2D:
			area = i
						
	#Para todas as areas pegas, ele adiciona o sinal que verifica se um inimigo esta na luz
	area.body_entered.connect(_init_time_hit)
	area.body_exited.connect(_reset_time_hit)
		
		
func _process(delta: float) -> void:
			
	for body in enemies_on_light.keys():
		if body == null:
			continue
	
		print(body)
	
	# vai incrementando o tempo conforme ele fica na area
		enemies_on_light[body] += delta
		
		# se der 2 segundos, ele zera o tempo e da o dano
		if(enemies_on_light[body] >= 2.0):
			body.take_damage(damage) 
			enemies_on_light[body] = 0.0
		
	energie_logic()


func energie_logic():
	
	if(energie <= -1):
		set_activate(false)
	
	if(activate):
		energie -= 0.1
		#print("energie: ", energie)

func set_activate(mode: bool):
	
	activate = mode
	area.monitoring = activate
	area.visible = activate
					

func _init_time_hit(ene: CharacterBody2D):	
	enemies_on_light[ene.get_parent() as Enemie] = 0.0
	
#se ele sair, remove do verificador
func _reset_time_hit(ene: CharacterBody2D):
	enemies_on_light.erase(ene.get_parent())

	
	


	
	

	
