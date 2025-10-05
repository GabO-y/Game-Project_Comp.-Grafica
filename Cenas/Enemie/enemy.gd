extends Character

class_name Enemy

@export var speed = 200 #velocidade de movimentação
@export var damage = 1 #dano que o inimigo da

@export var body: CharacterBody2D #Corpo do inimigo
@export var anim: AnimatedSprite2D

@export var bar: ProgressBar #Barra de progresso
var player: Player #Proprio jogador

var position_target #Para onde ele deve andar
var atack_player = false #para verificar se esta atacando o player para ter que ficar parado
var dir: Vector2 = Vector2.ZERO #direção do inimigo, fiz pra facilitar com as animações
var is_active: bool = false
var knockback_force: float = 500.0
var is_dead: bool = false
var last_position: Vector2
#exclusivo dos fantasmas
var running_attack = false

var drop_table = [
	{"item": "Energy", "chance": 0.5},
	{"item": "Life", "chance": 0.3}
]
	
func _ready() -> void:
	
	player = Globals.player
	
	if level > 1:
		life *= 1 + (0.5 * level)
		damage *= 1 + (0.5 * level)
			
	for i in body.get_children():
		if i is ProgressBar:
			bar = i			

	if bar != null:
		bar.max_value = life
		bar.value = life
				
func _process(_delta: float) -> void:
	update_bar()
	
func update_bar():
	if bar == null:
		return
	bar.value = life

func disable():
	hide()
	is_active = false
	body.collision_layer = 0
	body.collision_mask = 0
	
func enable():
	show()
	is_active = true
	body.collision_layer = 1
	body.collision_mask = 1
	
func take_damage(damage: int):
	
	if is_dead: return
	
	life -= damage
	
	if life <= 0 and !is_dead:
		die()
	else:
		change_color_damage()

func knockback_logic():
	var knockback_dir = (body.global_position - player.player_body.global_position).normalized()
	body.velocity = knockback_dir * knockback_force
	
func die():
	
	if is_dead: return
		
	is_dead = true
	
	drop_logic()	
	
	set_physics_process(false)
	set_process(false)
	
	body.collision_layer = 0
	body.collision_mask = 0
	
	enemy_die.emit(self)
	
	await death_animation()
	queue_free()
	

func drop_logic():
	
	if !is_active: return
	
	for drop in drop_table:
		if randf() >= drop["chance"]:
			var item = drop["item"]
			#item.global_position = global_position
			#Globals.current_scene.add_child(item)
			
	var key = Globals.drop_key()
	
	if key != null:
		Globals.current_room.add_child(key)
		key.global_position = body.global_position


func change_color_damage():
	body.move_and_slide()
	
	var sprite = anim
	var original_color = sprite.modulate

	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = original_color
	
func death_animation():
	pass
	
func set_active(mode: bool):
	if mode:
		enable()
	else:
		disable()
	is_active = mode
	
signal enemy_die(ene: Enemy)
