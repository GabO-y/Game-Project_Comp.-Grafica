extends PowerUp

class_name RecoverAllHeartsPowerUp

func apply():
	Globals.player.hearts = Globals.player.max_heart
	Globals.player.update_hearts()
