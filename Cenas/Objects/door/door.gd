extends Area2D

class_name door

func _ready():
	# Conectando o sinal "body_entered" DESTE nó (self)
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	# Esta é a nossa linha de teste!
	print("COLISÃO DETECTADA! Um corpo entrou na porta.")
	if body.is_in_group("player"):
		
		get_tree().change_scene_to_file("res://Cenas/House/levels/room_1/room_1.tscn")
