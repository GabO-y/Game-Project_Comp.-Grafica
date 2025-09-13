extends CharacterBody2D
#
#var speed := 200
#var player: CharacterBody2D
#var min_dist := 55  # distância mínima para parar de se aproximar
#
#func _ready() -> void:
	#player = get_tree().get_first_node_in_group("player")
#
#func _physics_process(delta: float) -> void:
	#if player == null:
		#return
	#
	## Calcula vetor do inimigo até o player
	#var to_player = player.global_position - global_position
	#var distancia = to_player.length()
	#
	#if distancia > min_dist:
		#var dir = to_player.normalized()
		#velocity = dir * speed
	#else:
		#velocity = Vector2.ZERO  # para quando estiver próximo
#
	#move_and_slide()
