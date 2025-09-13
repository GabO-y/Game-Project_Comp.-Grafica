extends Node2D

class_name Character

var life = 100

func take_damage(damage: int):
	life -= damage
	print("life: ", life)
