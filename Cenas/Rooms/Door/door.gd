extends Node2D

class_name Door

@onready var area: Area2D;
var goTo #Room que ele deve ir

func _ready() -> void:
	for i in get_children():
		if i is Area2D:
			area = i
			area.body_entered.connect(_player_enter)
			break

func _player_enter(body: CharacterBody2D):
	
	var player: Player
	
	if !(body.get_parent() is Player):
		return
	else:
		player = body.get_parent()
		
	if !player.can_teleport:
		return
		
	for i in get_children():
		if i is Area2D:
			i.set_deferred("monitoring", false)	
			

	body.get_parent().can_teleport = false
	
	emit_signal("player_in", body, goTo)
	await get_tree().create_timer(0.1).timeout
	
	body.get_parent().can_teleport = true

signal player_in(player, goTo)
