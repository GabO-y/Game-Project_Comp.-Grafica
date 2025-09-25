extends Node

var current_scene: Room
var last_scene
var can_teleport = true
var player: Player
var die = false

func _process(delta: float) -> void:

	if Input.is_key_pressed(KEY_SPACE) and die:
		die = false
		get_tree().paused = false
		get_tree().reload_current_scene()
		
	process_mode = Node.PROCESS_MODE_ALWAYS
		
func desable_room():
	current_scene.desable()
	
func enable_room():
	current_scene.enable()
	
func set_teleport(can: bool):
	if can:
		get_tree().create_timer(0.5).timeout
		Globals.can_teleport = true
	else:
		Globals.can_teleport = false


func is_clean_room():
	return current_scene.is_clean()
