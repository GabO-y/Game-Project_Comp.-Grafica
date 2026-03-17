extends Node2D

class_name CompostAtrribute

var sub_attr: Dictionary = {}

func set_attr(name: String, max: float, min: float, max_level: int = 0):
	if sub_attr.has(name):
		sub_attr[name] = {
			"attr": SimpleAttribute.new(max, min),
			"level": sub_attr[name]["level"]
		}
	else:
		sub_attr[name] = {
				"attr": SimpleAttribute.new(max, min, max_level),
				"level": 1
			}

func get_value(name: String, level: int = 0):
	var aux: Dictionary = sub_attr[name]
	var attr: SimpleAttribute = aux["attr"]
	if level <= 0:
		level = aux["level"]
	return attr.get_value(level)

func set_level(name: String, level: int):
	if sub_attr.has(name):
		sub_attr[name]["level"] = level
	
