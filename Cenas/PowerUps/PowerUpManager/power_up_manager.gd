extends Node2D

class_name PowerUpManager

var availabel_ups: Array[String] = ["FairyPowerUp", "LightBallPowerUp", "CollectCoinsPowerUp", "RecoverAllHeartsPowerUp", "MultiplierCoinsPowerUp"]

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
	if availabel_ups.size() < 3:
		ups = availabel_ups
	else:
		while ups.size() < 3:
			var up: String = availabel_ups.pick_random()
			if up in ups:
				continue
			ups.append(up)
					
	var r: Array[PowerUp] = []
	for up in ups:
		var path: String = str("res://Cenas/PowerUps/", up, "/", up, ".tscn")
		r.append(load(path).instantiate())
	return r
	
func get_power_up(name: String) -> PowerUp:
	var power_up: PowerUp = load("res://Cenas/PowerUps/" + name + "/" + name + ".tscn").instantiate()
	if power_up: 
		return power_up
	else:
		return	load("res://Cenas/PowerUps/FairyPowerUp/FairyPowerUp.tscn").instantiate()

func _organizate_light_balls() -> void:
	var l_balls: Array = power_up_in_scene["LightBall"]
	var size: int = l_balls.size()
	
	var delta: float = deg_to_rad(360.0 / size as float)
	
	for i in range(size):
		l_balls.get(i).r = delta * (i + 1)
		
func reset():
	power_up_in_scene = {
	"Fairy": [],
	"LightBall": []
	}
	Globals.multiplier_coins_bonus = 1.0
