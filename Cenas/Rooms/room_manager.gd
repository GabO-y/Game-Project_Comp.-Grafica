extends Node2D

var rooms = []

func _ready() -> void:		
	
	for room in get_tree().get_nodes_in_group("rooms"):
		room.visible = false
		for door in room.get_children():
			if door is Door:
				door.player_in.connect(_teleport)
				door.area.monitoring = false

func _teleport(player, goTo):
	
	Globals.desable_room()
	Globals.current_scene = goTo.get_parent()
	Globals.enable_room()

	player.global_position = goTo.area.global_position
	
func match_doors(r_current: String, r_target: String):

	var door_current: Door
	var door_target: Door

	r_current = r_current.to_lower()
	r_target = r_target.to_lower()

	var d_current = r_target.to_lower()
	var d_target = r_current.to_lower()
	
	for room in get_tree().get_nodes_in_group("rooms"):
		
		if room.name.to_lower() == r_current:
			for i in room.get_children():
				if i is Door:
					if i.name.to_lower() == d_current:
						door_current = i

		if room.name.to_lower() == r_target:
			for i in room.get_children():
				if i is Door:
					if i.name.to_lower() == d_target:
						door_target = i
	
	if door_current == null:
		print(d_current, " nao encontrado")
		return
	if door_target == null:
		print(d_target, " nao encontado")
		return

	door_current.goTo = door_target
	door_target.goTo = door_current
	
func showInfo():
	for i in get_children():
		if i is Room:
			i._doors()
