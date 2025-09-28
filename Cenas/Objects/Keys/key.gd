extends Item

class_name Key

var what_open: Array[String]
@export var label: Label
@export var anim: AnimationPlayer

static func generate_key(name: String):
	
	var scene_key = load("res://Cenas/Objects/Keys/Key.tscn")
	
	var key = scene_key.instantiate()
		
	var rooms_name = name.split(",") 
	
	key.what_open.append(str(rooms_name[0]))
	key.what_open.append(str(rooms_name[1]))

	key.name = name
	
	key.label.text = str(rooms_name[1])

	return key
	
func equals(key: Key):
	if what_open[0] == key.what_open[0] and what_open[1] == key.what_open[1]:
		return true
	if what_open[0] == key.what_open[1] and what_open[1] == key.what_open[0]:
		return true
	return false
	
func play_scale_key():
	anim.play("get_key")
	return anim.animation_finished
	
