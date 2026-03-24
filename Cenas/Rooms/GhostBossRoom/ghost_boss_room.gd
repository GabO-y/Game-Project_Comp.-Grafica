extends BossRoom

class_name GhostBossRoom

@export var segs_to_ghost_room: Node2D

func _ready() -> void:
	super._ready()
	
func reset():
	super.reset()
	if boss:
		if boss in get_children():
			remove_child(boss)
		boss.queue_free()
	
	#if is_instance_valid(boss):
		#boss.queue_free()
		#
	#boss = load("res://Cenas/Enemy/Bosses/newGhostBoss/GhostBoss.tscn").instantiate() as GhostBoss
	#add_child(boss)
	
	#boss.room = self
	#boss.reset()
	
	#boss.global_position = spot_boss_spawn.global_position

func spawn_boss():
	if boss in get_children():
		remove_child(boss)
	boss = load("res://Cenas/Enemy/Bosses/GhostBoss/GhostBoss.tscn").instantiate()
	add_child(boss)
