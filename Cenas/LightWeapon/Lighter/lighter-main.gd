extends LightWeapon

class_name Lighter

func _ready() -> void:
	super._ready()
	
	attributes["damage"] = CompostAtrribute.new()
	attributes["frames_to_damage"] = CompostAtrribute.new()
	attributes["distance"] = CompostAtrribute.new()
	
	attributes["frames_to_damage"].set_attr("value", 20, 40)
	attributes["frames_to_damage"].set_attr("price", 100, 10)
	
	attributes["damage"].set_attr("value", 5, 1)
	attributes["damage"].set_attr("price", 150, 10)
	
	attributes["distance"].set_attr("value", Vector2(2, 2), Vector2(1, 1))
	attributes["distance"].set_attr("price", 150, 10)

	

	
