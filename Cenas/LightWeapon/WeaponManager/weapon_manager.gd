extends Node2D

class_name WeaponManager

var weapons: Dictionary = {}
var weapons_infos: Dictionary = {}

var selected: LightWeapon
var selected_name: String

func _ready() -> void:
	weapons = {
		"Lantern" : 0,
		"Lighter" : 50,
		"FairyLight" : 50,
		"LightDash" : 50,
	}
	
	var aux_array: Array[LightWeapon]
	var aux_node: Node2D = Node2D.new()
	add_child(aux_node)
	
	for key in weapons.keys():
		var path: String = str("res://Cenas/LightWeapon/", key ,"/", key, ".tscn")
		
		weapons[key] = {
			"locked": true,
			"level": 1,
			"weapon" : load(path),
			"price": weapons[key]
		}
		
		var instance: LightWeapon = weapons[key]["weapon"].instantiate()
		aux_array.append(instance)
		aux_node.add_child(instance)
		

	await get_tree().process_frame
		
		
	for l in aux_array:
		var upgrades: Dictionary = {}
		for attr in l.attributes.keys():
			upgrades[attr] = 1
		weapons[l.name]["upgrades"] = upgrades
	for child in aux_node.get_children():
		aux_node.remove_child(child)
	remove_child(aux_node)	
	set_weapon("Lantern")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_ctrl"):
		print(weapons)

func set_weapon(name: String):
	for key in weapons.keys():
		if name.replace("_", "").to_lower() == key.to_lower():
			
			var w: LightWeapon = weapons[key]["weapon"].instantiate()
			var w_node: Node2D = Globals.player.weapon_node
			
			weapons[key]["locked"] = false
			
			for c in w_node.get_children():
				w_node.remove_child(c)
			w_node.add_child(w)
			
			selected = w
			selected_name = selected.name
			
			if weapons_infos.has(key):
				for attr in w.attributes.keys():
					w.attributes[attr].level = weapons_infos[key][attr]
			else:
				var infos: Dictionary
				for attr in w.attributes.keys():
					infos[attr] = w.attributes[attr].level
				weapons_infos[key] = infos
				
			
