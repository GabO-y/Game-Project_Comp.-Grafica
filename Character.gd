extends CharacterBody2D

var life = 100

func take_damage(damage: int):
	life -= damage
	print("vida: ", life)
