extends Control

class_name WeaponUpgradesScreen

@export var weapon_items: Control
@export var upgredes_item: Control

func update():
	
	for child in weapon_items.get_children():
		weapon_items.remove_child(child)
	
	var tab_infos: Dictionary = {
		"Lantern": {
			"name": "Lanterna",
			"icon": "res://Assets/LightArmor/Lantern/lantern_icon.png"
		},
		"Lighter": {
			"name": "Isqueiro",
			"icon": "res://Assets/LightArmor/Lighter/lighter_icon.png"
		},
		"FairyLight": {
			"name": "Pisca-Pisca",
			"icon": "res://Assets/LightArmor/FairyLight/fairy_light_icon.png"
		},
		"damage": {
			"name": "Dano"
		},
		"frames_to_damage": {
			"name": "Tempo para o Dano"
		},
		"frames_coldown_shoot": {
			"name": "Tempo de Recarga"
		}
	}
	
	var w_m: WeaponManager = Globals.weapon_manager
	var weapons: Dictionary = w_m.weapons
	
	for w in weapons.keys():
		if not tab_infos.has(w):
			continue
		
		var item: AvailableWeapons = load("res://Cenas/Menus/ShopMenu/UpgradesScreen/WeaponsUpgradesScreen/AvailableToSelect.tscn").instantiate()
		weapon_items.add_child(item)
					
		item.label_name.text = str(tab_infos[w]["name"])
				
		if weapons[w]["locked"]:
			item.label_price.text = str(weapons[w]["price"])
			item.label_price.modulate = Color.RED
		else:
			item.label_price.visible = false
			
		item.button.icon = load(tab_infos[w]["icon"])
		item.button.button_up.connect(buy_weapon.bind(w, weapons[w]))
		
		if w == w_m.selected.name:
			item.label_name.modulate = Color.GREEN
			for child in upgredes_item.get_children():
				upgredes_item.remove_child(child)
			var attributes: Dictionary = w_m.selected.attributes
			for attr in attributes.keys():
				var up: AvailableUpgrades = load("res://Cenas/Menus/ShopMenu/UpgradesScreen/Shered/AvailableUpgrades.tscn").instantiate()
				upgredes_item.add_child(up)
				var text: String = ""
				if tab_infos.has(attr):
					text = tab_infos[attr]["name"]
				else:
					text = attr
								
				var a: CompostAtrribute = attributes[attr]
				a.level = weapons[w]["upgrades"][attr]
								
				var price: int = int(a.get_attr("price"))
				
				var level: float = a.level 
				var max_level: float = a.max_level
	
				up.label_name.text = text
				up.label_price.text = str(price) if level < max_level else "MAX"
				up.progress_bar.value = level / max_level 
				up.button.button_up.connect(buy_upgrade.bind(w, attr, attributes))

func buy_weapon(weapon_name: String, weapon_infos: Dictionary):
	
	var price: int = weapon_infos["price"]
	
	if not weapon_infos["locked"]:
		Globals.weapon_manager.set_weapon(weapon_name)
	elif Globals.player.coins < price:
		print("sem money")
		return
	else:
		Globals.player.coins -= price
		Globals.player.update_label_coins()
		Globals.weapon_manager.set_weapon(weapon_name)

	update()
	
func buy_upgrade(weapon_name, attr_name, attr):
	
	var a: CompostAtrribute = attr[attr_name]
		
	var price: int = int(a.get_attr("price"))
	if Globals.player.coins < price:
		return
	if a.level >= a.max_level:
		return

	Globals.player.coins -= price
	
	var level: int = Globals.weapon_manager.weapons[weapon_name]["upgrades"][attr_name] + 1
	Globals.weapon_manager.weapons[weapon_name]["upgrades"][attr_name] = level
	Globals.weapon_manager.selected.attributes[attr_name].level = level
	Globals.player.update_label_coins()
	update()
