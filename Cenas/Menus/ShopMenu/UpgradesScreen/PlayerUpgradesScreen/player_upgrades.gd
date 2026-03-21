extends Control

class_name PlayerUpgradeScreen

@export var upgrades_node: Control
@export var shop_menu: ShopMenu

@export var scroll_container: ScrollContainer

var idx_selected: int = 0

var is_clicking: bool = false


func _ready() -> void:
	await get_tree().process_frame
	update()
	
func update():
	
	shop_menu.scroll_focus = scroll_container
	find_focus()
	
	for child in upgrades_node.get_children():
		upgrades_node.remove_child(child)
		
	var tab_infos: Dictionary = {
		"life": {
			"name": "Vida"
		},
		"speed": {
			"name": "Velocidade"
		},
		"dash_duration": {
			"name": "Duração do Dash"
		},
		"dash_coldown": {
			"name": "Recarga do Dash"
		},
		"invencible_time": {
			"name": "Tempo De Invensibilidade"
		}
	}
	
	var attributes: Dictionary = Globals.player.attributes
	for attr in attributes.keys():
		
		var name: String
		
		if tab_infos.has(attr):
			name = tab_infos[attr]["name"]
		else:
			name = attr
			
		var item: AvailableUpgrades = load("res://Cenas/Menus/ShopMenu/UpgradesScreen/Shered/AvailableUpgrades.tscn").instantiate()
		upgrades_node.add_child(item)
			
		item.label_name.text = name

		var max_l: float = attributes[attr].max_level
		var l: float = attributes[attr].level
		
		var price: int = int(attributes[attr].get_attr("price"))
		item.progress_bar.value = l / max_l
		
		var price_text: String
		
		if l < max_l:
			price_text = str(price)
			item.button.button_up.connect(buy_upgrade.bind(attributes, attr, price))
		else:
			price_text = "MAX"
		item.label_price.text = price_text
	
	update_focus()
	
func find_focus():
	var focus: Control = get_viewport().gui_get_focus_owner()
	var idx: int = 0
	for child in upgrades_node.get_children():
		if child.button == focus:
			idx_selected = idx
			return
		idx += 1
	
func update_focus():
	upgrades_node.get_child(idx_selected).button.grab_focus()

func buy_upgrade(attr: Dictionary, name: String, price: int):
	if not Globals.god_vars["player_infinity_coins"]:
		if Globals.player.coins < price:
			shop_menu.insufficiente_coin_effect()
			return
		Globals.player.coins -= price
	shop_menu.update_coin()
	Globals.player.update_label_coins()
	attr[name].level += 1
	Globals.player.update_status(name)
	update()
