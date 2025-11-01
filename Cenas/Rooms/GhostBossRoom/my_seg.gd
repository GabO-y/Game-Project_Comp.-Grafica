extends Node2D

class_name MySeg

@export var area: Area2D
var shape: SegmentShape2D

func _ready() -> void:
	
	for child in area.get_children():
		if child is CollisionShape2D:
			shape = child.shape as SegmentShape2D
			if !shape:
				push_error("SHAPE NEED BE SEGMENT SHAPE 2D: ", get_path())
				get_tree().quit()

func get_p(i: int) -> Vector2:
	match i:
		1: return shape.a
		2: return shape.b
		
	print("necessário ser de 1 a 2: ", get_path())
	return Vector2.ZERO
	
func get_x(i: int) -> float:
	return get_p(i).x
	
func get_y(i: int) -> float:
	return get_p(i).y
	
