# room_1.gd
extends Node2D

var cena_porta = preload("res://Cenas/Objects/door/door.tscn")


func _ready() -> void:

	

	# porta - tem que modificar depois
	var door = cena_porta.instantiate()
	door.position = Vector2(900, 300)
	add_child(door)
