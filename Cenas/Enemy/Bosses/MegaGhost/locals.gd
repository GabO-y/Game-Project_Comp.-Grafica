extends Node2D

class_name LocalVar
	
var already_center = 0
var mid_already_vanish = 0
var already_check_vanish = false

signal goint_to_center
		
func _on_goint_to_center() -> void:
	
	already_center += 1
	
	if already_center >= 4:
		mid_already_vanish += 1
		already_center = 0
	if mid_already_vanish == 2:
		free_all.emit()
		emerge_boss.emit()
		mid_already_vanish = 0
		
signal emerge_boss

signal free_all

	
