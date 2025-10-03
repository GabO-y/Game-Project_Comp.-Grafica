extends Node2D

@onready var game_over_anim := $GameOver/AnimationPlayer

func _finish_round(player: Player):
				
	game_over_anim.play("fade_to_black")
	get_tree().paused = true
	Globals.die = false
	await get_tree().create_timer(5).timeout
	Globals.die = true

	
