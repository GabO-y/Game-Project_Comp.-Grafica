extends Node2D

class_name MenuManager

var is_in_menu: bool = false
var menus: Array[Menu] = []

var current_menu: Menu

func _ready() -> void:
	
	for child in get_children():
		if child.name == "Menus":
			for menu in child.get_children():
				menus.append(menu)
				menu.manager = self
				menu.process_mode = Node.PROCESS_MODE_ALWAYS
				
func reset():
	
	for menu in menus:
		menu.reset()
		
	is_in_menu = false
	current_menu = null
