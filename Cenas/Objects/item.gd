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
	
	var dir = global_position.direction_to(Globals.player_pos).normalized()
	
	if global_position.distance_to(Globals.player_pos) < 10:
		dir = Vector2.ZERO
			
	position += dir * 3
	
static func create_item(item_name: String, pos: Vector2) -> Item:
	
	var item: Item
	
	match item_name:
		"coin":  item = create_coin(pos)
		
	return item
	
static func create_coin(pos: Vector2) -> Item:
	var h = load("res://Cenas/Objects/Item.tscn").instantiate() as Item
	h.global_position = pos
	
	var spr = Sprite2D.new()
	spr.texture = load("res://Assets/Objects/Coins/coin_test.png")
	
	h.add_child(spr)
	spr.global_position = pos
	
	return h
	
