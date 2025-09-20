extends Node2D

class_name Character

@export var life = 100
@export var level = 1

func take_damage(damage: int):
	life -= damage
	print("life: ", life)
