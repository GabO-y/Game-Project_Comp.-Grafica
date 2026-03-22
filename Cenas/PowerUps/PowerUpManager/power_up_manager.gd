extends Node2D

class_name PowerUpManager

var up_quant: int = 1

var ene_to_up: SimpleAttribute = SimpleAttribute.new(30, 1, 9)
var ene_defeated: int = 0

var availabel_ups: Array[String] = ["FairyPowerUp"]

func _process(delta: float) -> void:
	
	if ene_defeated >= ene_to_up.get_value(up_quant):
		var menu: PowerUpMenu = Globals.house.power_up_menu
		menu.power_ups = get_power_ups()
		menu.setup_state(Menu.MenuState.ENABLE)
		ene_defeated = 0
		up_quant += 1
	
func get_power_ups():
	var ups: Array[String]
	for i in range(3):
		if ups.size() == availabel_ups.size():
			break
		var up: String = availabel_ups.pick_random()
		while up in ups:
			up = availabel_ups.pick_random()
		ups.append(up)
	var r: Array[PowerUp] = []
	for up in ups:
		var path: String = str("res://Cenas/PowerUps/", up, "/", up, ".tscn")
		r.append(load(path).instantiate())
	return r

	
