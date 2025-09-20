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
	
	if !Globals.is_clean_room():
		return
		
	if !Globals.can_teleport:
		return
		
	var player: Player
	
	if !(body.get_parent() is Player):
		return
	else:
		player = body.get_parent()
		
		
	for i in get_children():
		if i is Area2D:
			i.set_deferred("monitoring", false)	
			
	
	print(Globals.current_scene.is_clean())
	
	emit_signal("player_in", body, goTo)
	
	print(Globals.is_clean_room())
	
	
signal player_in(player, goTo)
