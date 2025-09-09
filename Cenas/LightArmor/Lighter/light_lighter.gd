extends Area2D

var damage = 5

var enemies_on_light = {}

func _ready() -> void:
	body_entered.connect(_init_time_hit)
	body_exited.connect(_reset_time_hit)
	
#se o inicia o tempo que o inimigo esta na luz
func _init_time_hit(ene: Enemie):
	enemies_on_light[ene] = 0.0
	
#se ele sair, remove do verificador
func _reset_time_hit(ene: Enemie):
	enemies_on_light.erase(ene)

func _process(delta: float) -> void:
	
	# vai passar pro todos os inimigos que estao na luz
	for body in enemies_on_light.keys():
		
		# vai incrementando o tempo conforme ele fica na area
		enemies_on_light[body] += delta
		
		# se der 2 segundos, ele zera o tempo e da o dano
		if(enemies_on_light[body] >= 2.0):
			(body as Enemie).take_damage(damage) 
			enemies_on_light[body] = 0.0
			
	
