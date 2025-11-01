extends Item

class_name Key

var door1: Door
var door2: Door

func start_chase_player():
	super.start_chase_player()
	curve.set_t(0.007)
	
func use():
	door1.is_locked = false
	door2.is_locked = false
	queue_free()
	
