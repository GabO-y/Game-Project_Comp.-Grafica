extends Node2D

class_name ItemManager

@export var room_manager: RoomManager
@export var key_manager: KeyManager
# É para armazenar todos os items dropados numa sala
@export var items_node: Node2D

enum item_type {COIN, KEY}

var key_to_free: Key

#var drops = {
	#"comum": {"chance" : 0.5, "item": [
		#"heart",
		#"coin"
	#]},
	#"rare": {"chance": 0.7, "item": [
		#"power"
	#]}
#}

var is_finish_get_key: bool = false

var drops = {
	"comum": {"chance" : 0.0, "item": [
		"coin"
	]}
}

func _process(delta: float) -> void:
	
	if is_finish_get_key:
		if Input.is_anything_pressed():
			finish_get_key()

func _ready() -> void:
	if room_manager == null:
		push_error("ROOM MANAGER CAN'T BE NULL: ", get_path())
		get_tree().quit()
		return
		
func create_item(item_name: String, pos: Vector2 = Vector2.ZERO) -> Item:
	
	var item: Item
	
	match item_name:
		"coin":  item = create_coin(pos)
		"key": item = setup_key(key_manager.create_key(room_manager.get_room_logic()))
				
	item.manager = self
				
	return item
	
func create_coin(pos: Vector2) -> Item:
	var item = load("res://Cenas/Item/Item.tscn").instantiate() as Item
	
	item.global_position = pos
	item.type = item_type.COIN
	
	var spr = Sprite2D.new()
	spr.texture = load("res://Assets/Objects/Coins/coin_test.png")
	
	item.add_child(spr)
	spr.global_position = pos
	
	return item

func setup_key(key: Key) -> Item:
		
	if !key: return
	
	call_deferred("add_child", key)
	
	key.collected.connect(_collect_item)
	
	key.type = item_type.KEY
	key.global_position = key.door1.area.global_position
	key.start_chase_player()
	
	key_to_free = key

	return key
	
func create_key_auto():
	create_item("key")
	
# Tenta dropar baseado no sinal que o inimigo emite quando morre
func try_drop(ene: Enemy):
	
	var pos = ene.body.global_position
	var p = randf()

	var item: String = ""

	for i in drops.keys():
		if p > drops[i]["chance"]:
			item = drops[i]["item"].pick_random()
			
	if not item.is_empty():
		drop(item, pos)
		
func drop(item: String, pos: Vector2):
	
	var i = create_item(item, pos)
	
	i.manager = self
	i.collected.connect(_collect_item)
		
	i.start_drop_down()
		
	items_node.add_child(i)
	
	# Caso vc consiga matar os monstros rapido o suficiente,
	# há chance do sinal que é emitido para verificar se
	# a sala atual está limpa, sejá associonado, antes do
	# item entrar na cena, ai ele não percegue, ent verifaca aqui tbm
	if room_manager.current_room.get_is_clear():
		i.start_chase_player()

# Fiz no caso do player trocar de sala, mas nem todos os items foram coletados
# É ativado com "changed_room" do RoomManager
func get_all_items():
	
	items_node.visible = false
	
	for item in items_node.get_children():
		item.collected.emit(item)
		
	items_node.visible = true
	
# Chamado no Room
func make_items_chase_player():
	for item in items_node.get_children():
		item = item as Item 
		item.start_chase_player()	
		
func _collect_item(item: Item):
			
	match item.type:
		item_type.COIN:
			Globals.player.coins += 1
			Globals.player.update_label_coins()
			item.queue_free()
		item_type.KEY:
			await Globals.player.get_key_animation(item)
			is_finish_get_key = true
			
func finish_get_key():
	Globals.player.is_getting_key = false
	Globals.player.set_process(true)
	Globals.player.set_physics_process(true)
	is_finish_get_key = false
	if key_to_free:
		key_to_free.use()
	room_manager.current_room._clear_effects()
