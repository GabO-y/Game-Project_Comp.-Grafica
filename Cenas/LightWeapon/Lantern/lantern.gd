extends LightWeapon

class_name Lantern

func _ready() -> void:
		
	attributes["damage"] = CompostAtrribute.new()
	attributes["frames_to_damage"] = CompostAtrribute.new()
	attributes["distance"] = CompostAtrribute.new(5)
	
	attributes["frames_to_damage"].set_attr("value", 30.0, 50.0)
	attributes["frames_to_damage"].set_attr("price", 100.0, 10.0)
	
	attributes["damage"].set_attr("value", 10.0, 2.0)
	attributes["damage"].set_attr("price", 150.0, 10.0)
	
	attributes["distance"].set_attr("value", Vector2(2, 2), Vector2(1, 1))
	attributes["distance"].set_attr("price", 150.0, 10.0)
	
	super._ready()

	
	
	
func enable_state(delta: float):
	var dir: Vector2 = get_dir()
	rotation = dir.angle() # * (PI / 2.0)
	super.enable_state(delta)
