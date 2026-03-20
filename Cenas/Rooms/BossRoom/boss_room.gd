extends Room

class_name BossRoom

@export var boss: Boss
@export var spot_boss_spawn: Marker2D

func _ready() -> void:
	# boss.room = self
	super._ready()

func desable():
	if finish:
		for door in doors:
			door.all_lock()
	super.desable()
	
func enable():
	spawn_boss()
	boss.global_position = spot_boss_spawn.global_position
	super.enable()
	
#func reset():
	#super.reset()
	#
	#print("BOSSSSSSS RESETADO")
	#boss.global_position = spot_boss_spawn.global_position - global_position

func spawn_boss():
	pass
