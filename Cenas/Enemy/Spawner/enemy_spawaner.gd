extends Node2D

class_name Spawn

var room: Room

func spawn(ene_name: String) -> Enemy:
	var path = str("res://Cenas/Enemy/", ene_name, "/", ene_name, ".tscn")
	var ene = load(path).instantiate() as Enemy
	ene.global_position = global_position 
	return ene
	
