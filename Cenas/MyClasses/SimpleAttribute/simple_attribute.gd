extends Node2D

class_name SimpleAttribute

var max_value: float 
var min_value: float 
var max_level: int 
var min_level: int 

func _init(max: float = 1.0, min: float = 1.0, max_l: int = 1, min_l: int = 1) -> void:
	max_value = max
	min_value = min
	max_level = max_l
	min_level = min_l
	
func get_value(level: int):
	
	if level <= min_level:
		return min_value
	if level >= max_level:
		return max_value
	
	var value: float = max_value - min_value
	var delta: float = value / (max_level - min_level)
		
	return min_value + (delta * level)
	
