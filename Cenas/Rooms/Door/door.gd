extends Node2D

class_name Door

@export var area: Area2D;
var goTo #Room que ele deve ir
@export var is_locked: bool			
@export var light: PointLight2D 

func _ready():
	area.body_entered.connect(_player_enter)

func _player_enter(body):
	
	if !Globals.is_clean_room():
		return
		
	if !Globals.can_teleport:
		return
		
	if is_locked:
		return
		
	var player: Player
	
	if !(body.get_parent() is Player):
		return
	else:
		player = body.get_parent()
		
	var contains_key = false
		
	for i in player.items:
		if i is Key:
			if name in i.what_open:
				contains_key = true
				break
		
	for i in get_children():
		if i is Area2D:
			i.set_deferred("monitoring", false)	
			
	print(Globals.current_room.is_clean())
	
	emit_signal("player_in", body, goTo)
	
	print(Globals.is_clean_room())
		
		
func turn_light(turn: bool):
	light.visible = turn
		
	
signal player_in(player, goTo)
