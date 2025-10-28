extends Node2D

class_name Item

@export var sprite: Sprite2D
@export var area: Area2D
@export var manager: ItemManager

var dist = 1
var type

var is_to_chase_player = false

func _ready() -> void:
	
	area.collision_mask = Globals.layers["player"]
	
	z_index = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	

func _process(delta: float) -> void:
	if is_to_chase_player:
		chase_player()
		
func chase_player():
	
	var dir = global_position.direction_to(Globals.player_pos).normalized()
	
	if global_position.distance_to(Globals.player_pos) < dist:
		dir = Vector2.ZERO
			
	position += dir * 3
	
func start_chase_player():
#   Sopostamente a logica de fazer uma curva antes de ir pro player, dps ir pro player

	is_to_chase_player = true

	print("start_chase_player: Item, precisa terminar")
	pass
	
func _on_player_body_entered(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if player == null: return
	
	collected.emit(self)
			
signal collected(item: Item)
