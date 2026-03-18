extends Control

class_name PlayerUpgradeScreen

@export var upgrades_node: Control

func _ready() -> void:
	
	await get_tree().process_frame
	update()

func update():
	
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

			
		
		
func buy_upgrade(attr: Dictionary, name: String, price: int):
	if Globals.player.coins < price:
		return
		
	Globals.player.coins -= price
	Globals.player.update_label_coins()
	attr[name].level += 1
	Globals.player.update_status(name)
	update()
