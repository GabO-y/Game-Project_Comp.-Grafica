extends Node2D

class_name Room

func _doors():
	print("Door: ", name)
	for i in get_children():
		if i is Door:
			print(i.name, " goTo ", i.goTo.name)
			
	print("\n\n")
