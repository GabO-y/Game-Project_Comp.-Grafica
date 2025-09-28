extends Node2D

class_name Item

@export var sprite: Sprite2D
@export var area: Area2D
var player: Player
var is_to_chase_player = false

func _ready() -> void:
	player = Globals.player
	z_index = 100
	z_as_relative = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if is_to_chase_player:
		chase_player()
		
func chase_player():
	
	var dir = global_position.direction_to(player.player_body.global_position).normalized()
	
	if global_position.distance_to(player.player_body.global_position) < 10:
		dir = Vector2.ZERO
			
	position += dir * 3
