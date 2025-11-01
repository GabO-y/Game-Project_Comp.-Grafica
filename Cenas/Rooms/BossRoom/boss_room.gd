extends Room

class_name BossRoom

@export var boss: Boss

func _ready() -> void:
	boss.room = self
	super._ready()

func desable():
	
	print(finish)
	
	if finish:
		for door in doors:
			door.all_lock()
	
	if is_instance_valid(boss):
		boss.desable()
		
	super.desable()
	
func enable():
	boss.enable()
	super.enable()

func _check_clear():
	if not is_instance_valid(boss): return true
	return boss.is_dead
	
func switch_process(mode: bool):	
	super.switch_process(mode)
	if is_instance_valid(boss):
		boss.set_active(mode)
