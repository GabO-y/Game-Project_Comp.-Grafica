extends Node2D

class_name Room

@export var finish = false
var spaweners = []

func _ready() -> void:
	for spawn in get_children():
		if spawn is Spawn:
			spaweners.append(spawn)
			
func is_clean() -> bool:
	
	for i in get_children():
		if i is Spawn:
			if i.enemies.size() != 0: return false
			if i.enemies_already_spawner < i.limit_spawn: return false
	return true
