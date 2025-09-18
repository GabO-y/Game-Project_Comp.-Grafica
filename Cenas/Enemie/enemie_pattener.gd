extends Character

class_name Enemie

var speed = 20 #velocidade de movimentação
var damage = 1 #dano que o inimigo da
var idleTime = 0 #Tempo que esta sem caçar o inimigo (usado para ele ir para outros pontos, caso nao esteja caçando)

var bar: ProgressBar #Barra de progresso
var body: CharacterBody2D #Corpo do inimigo
var chaseArea: Area2D #Area que eu fica patrulhando
var player #Proprio jogador
var positionTarget #Para onde ele deve andar
var sizeChaseArea = 100 #Tamanho da area que um inimigo tem em perseguição
var atack_player = false #para verificar se esta atacando o player para ter que ficar parado
var enemie_active = false #Caso o player nao estaja na sala desse inimigo, ele fica desativado

func _on_light_area():
	return self
	
func _ready() -> void:
	player = null

	for i in get_children():
		if i is CharacterBody2D:
			body = i
			
	for i in body.get_children():
		if i is ProgressBar:
			bar = i			
		if i is Area2D:
			chaseArea = i
			for j in chaseArea.get_children():
				if j is CollisionShape2D:
					j.shape = CircleShape2D.new()
					j.shape.radius = sizeChaseArea

	#quando o player entra na area de view, ele ativa a função para perseguição
	chaseArea.body_entered.connect(_find_player)
	#se o player sair, ele volta a patrulhar
	chaseArea.body_exited.connect(_scape_player)
	
#	define a posição inicial que um monstro vai andar
	positionTarget = get_random_point_in_area(chaseArea)

	if bar != null:
		bar.max_value = life
		bar.value = life

func _process(_delta: float) -> void:
	
	update_bar()
	
	if life <= 0:
		set_process(false)
		visible = false

func update_bar():
	if bar == null:
		return
	bar.value = life

func _physics_process(delta: float) -> void:
	if !enemie_active: return
	
	var lastPosition = Vector2(positionTarget.x, positionTarget.y)

	if player == null:

		idleTime += delta

		if idleTime >= 3:
			positionTarget = get_random_point_in_area(chaseArea)
			idleTime = 0
	else:
		positionTarget = player.global_position
		
	if atack_player:
		positionTarget = lastPosition
		

	var direction = (positionTarget - body.global_position).normalized()

	# Aplica movimento
	body.velocity = direction * speed
	body.move_and_slide()
	
func get_random_point_in_area(area: Area2D) -> Vector2:
	var shape = area.get_node("ViewArea").shape as CircleShape2D
	var radius = shape.radius
	var angle = randf_range(0, TAU)
	var distance = randf_range(0, radius)
	return area.global_position + Vector2(cos(angle), sin(angle)) * distance

func _find_player(_body: CharacterBody2D):	
	if body.get_parent() is Player:
		player = body
	else: return
	
	for i in chaseArea.get_children():
		if i is CollisionShape2D:
			(i.shape as CircleShape2D).radius *= 2
			
func _scape_player(_body: CharacterBody2D):
	player = null
	for i in chaseArea.get_children():
		if i is CollisionShape2D:
			(i.shape as CircleShape2D).radius = sizeChaseArea

		
	

	

	
	
	
	

	
	
