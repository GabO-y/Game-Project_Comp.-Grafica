extends Node2D

class_name SimpleAttribute

var max_value: Variant
var min_value: Variant
var max_level: int 

func _init(max: Variant = 1.0, min: Variant = 1.0, max_l: int = 1) -> void:
	max_value = max
	min_value = min
	max_level = max_l
	
func get_value(level: int):
	if level >= max_level:
		return max_value
	if level <= 1:
		return min_value
	var delta = (max_value - min_value) / max_level 
	return min_value + (delta * level)
	
func _to_string() -> String:
	return str("\nmax_value: ", max_value, "\nmin_value: ", min_value, "\nmax_level: ", max_level)
