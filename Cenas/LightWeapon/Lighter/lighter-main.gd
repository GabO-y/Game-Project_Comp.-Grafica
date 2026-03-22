extends LightWeapon

class_name Lighter

func _ready() -> void:
	
	attributes["damage"] = CompostAtrribute.new()
	attributes["frames_to_damage"] = CompostAtrribute.new()
	attributes["distance"] = CompostAtrribute.new()
	
	attributes["frames_to_damage"].set_attr("value", 20.0, 40.0)
	attributes["frames_to_damage"].set_attr("price", 100.0, 10.0)
	
	attributes["damage"].set_attr("value", 5.0, 1.0)
	attributes["damage"].set_attr("price", 150.0, 10.0)
	
	attributes["distance"].set_attr("value", Vector2(2, 2), Vector2(1, 1))
	attributes["distance"].set_attr("price", 150.0, 10.0)
	
	super._ready()


	

	
