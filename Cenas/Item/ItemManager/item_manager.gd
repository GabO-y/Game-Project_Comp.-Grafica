extends Node2D

class_name ItemManager

@export var room_manager: RoomManager
@export var key_manager: KeyManager
@export var round_manager: RoundManagar

# É para armazenar todos os items dropados numa sala
@export var items_node: Node2D

var created_items: Dictionary

enum item_type {COIN, KEY}

var key_in_scene: Key

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
		"Coin"
	]}
}


func _ready() -> void:
	if room_manager == null:
		push_error("ROOM MANAGER CAN'T BE NULL: ", get_path())
		get_tree().quit()
		return
		
	round_manager = room_manager.round_manager
		
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_0):
		if  created_items.has("coin"): 
			for c in created_items["coin"]:
				(c as Coin).setup_state(Item.ItemState.CHASING)
		
func drop_coin(pos: Vector2) -> Coin:
	return drop("Coin", pos)
	var coin: Coin = load("res://Cenas/Item/Coin/Coin.tscn").instantiate() as Coin
	Globals.house.add_child(coin)
	coin.global_position = pos
	coin.manager = self
	if not created_items.has("coin"):
		created_items["coin"] = []
	created_items["coin"].append(coin)
	coin.setup_state(Item.ItemState.DROPING)
	return coin
	
func drop(item_name: String, pos: Vector2) -> Item:
		
	var path: String = str("res://Cenas/Item/", item_name, "/", item_name, ".tscn")
	var item: Item = load(path).instantiate() as Item
	if not item: return null
	
	items_node.add_child(item)
	
	item.global_position = pos
	item.manager = self
	
	if not created_items.has(item_name):
		created_items[item_name] = []
		
	created_items[item_name].append(item)
	item.setup_state(Item.ItemState.DROPING)
	
	return item

func create_item(item_name: String, pos: Vector2 = Vector2.ZERO) -> Item:
	var item: Item
	if item_name == "key":
		if room_manager.current_room.already_drop_key:
			return
	match item_name:
		"coin": 
			item = create_coin(pos)
		"key": item = setup_key(key_manager.create_key_logic())
				
	if item_name == "key":
		if !item:
			print("chave não gerada")
			return
			
	if item is Key:
		if Globals.only_use_key:
			item.use()
			return
				
	return item
	
func create_coin(pos: Vector2) -> Item:
	var item = load("res://Cenas/Item/Coin/Coin.tscn").instantiate() as Coin
	item.global_position = pos
	return item

func setup_key(key: Key) -> Item:
		
	if !key: return
		
	call_deferred("add_child", key)
	
	#key.collected.connect(_collect_item)
	
	key.type = item_type.KEY
	
	if room_manager.last_ene_pos == Vector2.ZERO:
		key.global_position = key.door1.area.global_position
	else:
		key.global_position = room_manager.last_ene_pos

	key.start_chase_player()
	
	key_in_scene = key
	
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
		drop_by_name(item, pos)
		
func drop_by_name(item: String, pos: Vector2):
	var i: Item = drop(item, pos)
	if not Globals.round_manager.is_in_round:
		i.setup_state(Item.ItemState.CHASING)
	
	#
	#var i = create_item(item, pos)
		#
	#i.manager = self
	#
	#i.collected.connect(_collect_item)
			#
	#i.start_drop_down(create_defalt_drop_curve(i.global_position))
		#
	#items_node.add_child(i)
	#print(items_node)
	
	## Caso vc consiga matar os monstros rapido o suficiente,
	## há chance do sinal que é emitido para verificar se
	## a sala atual está limpa, sejá associonado, antes do
	## item entrar na cena, ai ele não percegue, ent verifaca aqui tbm
	#if not round_manager.is_round_playing:
		##i.start_chase_player()
		#i.setup_state(Item.ItemState.CHASING)

# Fiz no caso do player trocar de sala, mas nem todos os items foram coletados
# É ativado com "changed_room" do RoomManager
func get_all_items(room: Room):
	items_node.visible = false
	for item in items_node.get_children():
		item.collect(Globals.player.body)
		items_node.remove_child(item)
	items_node.visible = true
	
# Chamado no Room
func make_items_chase_player():
	print(created_items)
	for key in created_items.keys():
		for item in created_items[key]:
			if is_instance_valid(item):
				item.setup_state(Item.ItemState.CHASING)
				
	#for item in items_node.get_children():
		#item = item as Item 
		#item.start_chase_player()	
		
func _collect_item(item: Item):
	if Globals.player.is_dead:
		item.queue_free()
		return
	if item is Coin:
		Globals.conquited_coins += item.get_value()
		Globals.player.coins += item.get_value()
		Globals.player.update_label_coins()
		
		item.visible = false
		
		item.audio.finished.connect(item.queue_free)
		
		return

	match item.type:
		item_type.KEY:
			# caso a chave esteja indo em direçao a porta
			if item.is_going_to_door: return
			
			await Globals.player.get_key_animation(item)
			
			if not is_instance_valid(item): return
			item.is_key_moment = true

# caso o player atravesse a porta, mas não tenha pegado a chave
func finish_get_key():
	
	if key_in_scene:
		key_in_scene.use()
		Globals.player.is_getting_key = false
	
		Globals.player.set_process(true)
		Globals.player.set_physics_process(true)

		Globals.house.desable_camera()
		
func reset():
	
	for child in items_node.get_children():
		items_node.remove_child(child)
	
	created_items = {}

	is_finish_get_key = false
	key_in_scene = null
	
	Globals.player.is_getting_key = false
	key_manager.reset()
		
func create_defalt_drop_curve(item_pos: Vector2) -> MyCurve:
	
	var p0: Vector2 = item_pos
	var p1: Vector2 = p0
	var p2: Vector2 = p0
	var t: float = 0.03
	
	var right: bool = [true, false].pick_random()
	
	var x = randi_range(0, 20)
	if not right: x *= -1
	
	p1.y -= randi_range(30, 50)
	p2.x += x

	var drop_curve = MyCurve.new(p0, p1, p2, t)
	
	p1 = p2
	p1.y -= randi_range(10, 20)
	
	x = randi_range(10, 20)
	if not right: x *= -1
	
	p1.x += x * 0.25
	p2.x += x * 0.5
	
	p2.y += randi_range(0, 10)
	
	drop_curve.add_more_curve(p1, p2)
	
	return drop_curve
	
