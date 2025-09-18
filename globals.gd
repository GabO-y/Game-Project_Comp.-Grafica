extends Node

var current_scene
var last_scene

#func desable_room():
	#change_mode(false)
	#
#func enable_room():
	#change_mode(true)
	#
#func change_mode(mode: bool):
	#
	#current_scene.visible = mode
	#
	#for i in current_scene.get_children():
		#if i is Door:
			#i.area.set_deferred("monitoring", mode)	
