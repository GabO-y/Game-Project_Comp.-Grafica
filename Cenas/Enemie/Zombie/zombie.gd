extends Enemy

class_name Zombie

@export var agent: NavigationAgent2D
@export var time: Timer

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
		
	if !is_active:
		return

	var next_point = agent.get_next_path_position()
	
	var pla_pos = Globals.player.player_body.global_position
	
	dir = body.global_position.direction_to(next_point).normalized()
	
	if dir != Vector2.ZERO and body.global_position.distance_to(pla_pos) > 10:
		body.velocity = dir * speed
		body.move_and_slide()

func _ready() -> void:	
	agent.radius = 1.5
	time.timeout.connect(_make_path)

func _make_path():		
	agent.target_position = Globals.player.player_body.global_position 
