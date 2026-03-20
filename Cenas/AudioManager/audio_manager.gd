extends Node2D

class_name AudioManager

var audios: Dictionary

func _ready() -> void:
	for child in get_children():
		audios[child.name] = get_sounds(child)
			
func get_sounds(child: Node2D):
	var audios: Dictionary = {}
	for audio in child.get_children():
		audios[camel_to_snake(audio.name)] = audio
	return audios

func camel_to_snake(n: String):
	var i: int = 0
	var result: String = ""
	while i < n.length():
		if i == 0:
			result += n[i].to_lower()
		else:
			if n[i] == n[i].to_upper():
				result += "_"	
			result += n[i].to_lower()
		i += 1
	return result
	
func play(name: String, filter: String = ""):
	if filter == "":
		for key in audios.keys():
			play_by_filter(name, audios[key])
	else:
		play_by_filter(name, audios[filter])

func play_by_filter(name: String, audios: Dictionary):
	name = name.to_lower()
	if audios.has(name):
		audios[name].play()
	else:
		print("Sound not found\nname: ", name, "\naudios: ", audios)

		
		
		
		
		
		
		
		
		
		
		
		
	
			
	
