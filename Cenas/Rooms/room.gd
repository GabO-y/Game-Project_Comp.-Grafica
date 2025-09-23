extends Node2D

class_name Room

@export var finish = false
var spaweners = []
var doors: Array[Door]

func _ready() -> void:
	for child in get_children():
		if child is Spawn:
			spaweners.append(child)
		if child is Door:
			doors.append(child)
			
	
func is_clean() -> bool:
	for spawn in spaweners:
		if spawn is Spawn:			
			if !spawn.is_clean(): return false
	return true
	
	
func desable():
	switch_process(false)
			
func enable():
	switch_process(true)
			
func switch_process(mode: bool):
	if mode: show()
	else: hide()
	
	for item in get_children():
		if item is Door:
			item.area.set_deferred("monitoring", mode)
		if item is TileMapLayer:
			item.collision_enabled = mode
		if item is Spawn:
			item.switch(mode)
