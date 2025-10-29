extends Node2D

class_name Item

@export var sprite: Sprite2D
@export var area: Area2D
@export var manager: ItemManager

var dist = 1
var type

var is_to_chase_player = false
var curve: MyCurve

func _ready() -> void:
	
	area.collision_mask = Globals.layers["player"]
	
	z_index = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	if is_to_chase_player:
		chase_player()
		
# Pega um ponto da curva e atualiza para a nova pos do player
func chase_player():
	var p = curve.get_point_by_progress()
	position = p
	curve.set_p2(Globals.player_pos)
	
# Gera a curva que o item vai seguir ate o player
func start_chase_player():
	
	is_to_chase_player = true
	
	var p0 = global_position
	var p1 = p0
	var p2 = Globals.player_pos
	
	var dir: Vector2 = p0.direction_to(p2) * 80
	
	p1 -= dir 
	
	dir.x = [-1,1].pick_random()
	dir.y = [-1,1].pick_random()
	
	dir *= 80
		
	p1 -= dir
	
	curve = MyCurve.new(p0, p1, p2)

func _on_player_body_entered(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if player == null: return
	
	collected.emit(self)
			
signal collected(item: Item)
