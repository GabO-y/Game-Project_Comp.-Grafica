extends Node2D

class_name PowerUpManager

var availabel_ups: Array[String] = ["FairyPowerUp", "LightBallPowerUp"]

var power_up_in_scene: Dictionary = {
	"Fairy": [],
	"LightBall": []
}
		
func start():
	var menu: PowerUpMenu = Globals.house.power_up_menu
	menu.power_ups = get_power_ups()
	menu.setup_state(Menu.MenuState.ENABLE)
	
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

	
