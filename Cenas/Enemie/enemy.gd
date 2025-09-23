extends Character

class_name Enemie

var speed = 20 #velocidade de movimentação
var damage = 1 #dano que o inimigo da
var idleTime = 0 #Tempo que esta sem caçar o inimigo (usado para ele ir para outros pontos, caso nao esteja caçando)

var bar: ProgressBar #Barra de progresso
@onready var body: CharacterBody2D = $CharacterBody2D #Corpo do inimigo
var chase_area: Area2D #Area que eu fica patrulhando
var player: Player #Proprio jogador
var position_target #Para onde ele deve andar
var atack_player = false #para verificar se esta atacando o player para ter que ficar parado
var dir: Vector2 = Vector2.ZERO #direção do inimigo, fiz pra facilitar com as animações
var is_active: bool = false
var knockback_force: float = 500.0
	
func _ready() -> void:
	
	if level > 1:
		life *= 1 + (0.5 * level)
		damage *= 1 + (0.5 * level)
			
	for i in body.get_children():
		if i is ProgressBar:
			bar = i			

	#quando o player entra na area de view, ele ativa a função para perseguição
	#chase_area.body_entered.connect(_find_player)
	#se o player sair, ele volta a patrulhar
	#chase_area.body_exited.connect(_scape_player)
	
#	define a posição inicial que um monstro vai andar

	if bar != null:
		bar.max_value = life
		bar.value = life
		
func _process(_delta: float) -> void:
	update_bar()

func update_bar():
	if bar == null:
		return
	bar.value = life

func get_random_point_in_area(area: Area2D) -> Vector2:
	var shape = area.get_node("ViewArea").shape as CircleShape2D
	var radius = shape.radius
	var angle = randf_range(0, TAU)
	var distance = randf_range(0, radius)
	return area.global_position + Vector2(cos(angle), sin(angle)) * distance

func disable():
	hide()
	is_active = false
	body.collision_layer = 10
	body.collision_mask = 10
	
func enable():
	show()
	is_active = true
	body.collision_layer = 1
	body.collision_mask = 1
	
func take_damage(damage: int):
	
	
	body.move_and_slide()
	
	var sprite = $CharacterBody2D/AnimatedSprite2D
	var original_color = sprite.modulate

	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = original_color
	
	life -= damage
	print("life: ", life)
	
	
func knockback_logic():
	var knockback_dir = (body.global_position - player.player_body.global_position).normalized()
	body.velocity = knockback_dir * knockback_force
