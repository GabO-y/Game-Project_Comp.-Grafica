# room_1.gd
extends Node2D

# Variáveis de Cena
var cena_player = preload("res://Cenas/Player/player.tscn")
var cena_fantasma = preload("res://Cenas/Enemie/Fantasm/Fantasm.tscn")
var cena_porta = preload("res://Cenas/Objects/door/door.tscn")

# Variáveis de Jogo
var player: Character
var activateArmor = true
var armor: LightArmor
var infosModeActivate = false

var spawn_timer: Timer
var spawn_distancia_min: float = 100.0 # Distância mínima da borda da tela para o spawn
# para spanar fora da tela

func _ready() -> void:
	player = cena_player.instantiate()
	player.name = "Player"
	player.position = Vector2(400, 300)
	player.z_index = 10
	add_child(player)
	
	# porta - tem que modificar depois
	var door = cena_porta.instantiate()
	door.position = Vector2(900, 300)
	add_child(door)
	
	spawn_timer = Timer.new()
	spawn_timer.name = "SpawnTimer"
	spawn_timer.wait_time = 1.0 
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(spawnar_inimigo_fora_da_tela)
	add_child(spawn_timer)
	
	# iigual o codigo de house.gd
	armor = player.armor
	armor.set_activate(false)
	

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	infosMode()		
	toggle_activate_armor()


func spawnar_inimigo_fora_da_tela():
	# 1. Obter o retângulo da câmera/viewport
	var viewport_rect = get_viewport().get_visible_rect()
	
	# 2. Gerar uma posição aleatória fora desse retângulo
	var spawn_position = Vector2.ZERO
	var lado_aleatorio = randi_range(0, 3) # 0=Cima, 1=Baixo, 2=Esquerda, 3=Direita

	match lado_aleatorio:
		0: # Cima
			spawn_position.x = randf_range(viewport_rect.position.x, viewport_rect.end.x)
			spawn_position.y = viewport_rect.position.y - spawn_distancia_min
		1: # Baixo
			spawn_position.x = randf_range(viewport_rect.position.x, viewport_rect.end.x)
			spawn_position.y = viewport_rect.end.y + spawn_distancia_min
		2: # Esquerda
			spawn_position.x = viewport_rect.position.x - spawn_distancia_min
			spawn_position.y = randf_range(viewport_rect.position.y, viewport_rect.end.y)
		3: # Direita
			spawn_position.x = viewport_rect.end.x + spawn_distancia_min
			spawn_position.y = randf_range(viewport_rect.position.y, viewport_rect.end.y)

	# 3. Criar e posicionar o inimigo
	var novo_inimigo = cena_fantasma.instantiate()
	novo_inimigo.global_position = spawn_position
	novo_inimigo.z_index = 10
	add_child(novo_inimigo)
	
	print("Fantasma nasceu fora da tela em: ", novo_inimigo.global_position)


# funcoes de house.gd
func toggle_activate_armor() -> void:
	if Input.is_action_just_pressed("ui_toggle_armor"):
		armor.set_activate(activateArmor)
		activateArmor = !activateArmor

func infosMode():
	var label_node = get_node_or_null("labelPlayer")
	if not label_node:
		var labelPlayer = Label.new()
		labelPlayer.name = "labelPlayer"
		add_child(labelPlayer)
		label_node = labelPlayer
	label_node.text = """
	Life: %.0f
	Armor energie: %.0f
	""" % [player.life, armor.energie]
