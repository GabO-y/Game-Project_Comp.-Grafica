extends Node2D

class_name CompostAtrribute

var sub_attr: Dictionary = {}

var level: int = 1
var max_level: int

func _init(max: int = 10):
	max_level = max

func set_attr(name: String, max: float, min: float):
		sub_attr[name] =  SimpleAttribute.new(max, min, max_level)

func get_attr(name: String, level: int = 0):
	var attr: SimpleAttribute = sub_attr[name]
	if level <= 0:
		level = self.level
	return attr.get_value(level)

	
