extends CharacterBody2D

@export var speed: float = 100.0
@export var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
		
	if player == null:
		return

	# Calcula direção do inimigo até o player
	var direction = (player.global_position - global_position).normalized()

	# Aplica movimento
	velocity = direction * speed
	move_and_slide()
