extends Node

var current_scene
var last_scene
var can_teleport = true

func desable_room():
	change_mode(false)
	
func enable_room():
	change_mode(true)
	
func set_teleport(can: bool):
	if can:
		get_tree().create_timer(0.5).timeout
		Globals.can_teleport = true
	else:
		Globals.can_teleport = false


	
func change_mode(mode: bool):
	
	current_scene.visible = mode
	
	for i in current_scene.get_children():
		
		if i is Spawn:
			i.enemies_active = mode
			for ene in i.get_children():
				if ene is Enemie:
					ene.enemie_active = mode
		if i is Door:
			i.area.set_deferred("monitoring", mode)	
		if i is TileMapLayer:
			i.collision_enabled = mode

func is_clean_room():
	return current_scene.is_clean()
