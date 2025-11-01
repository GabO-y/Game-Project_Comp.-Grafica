extends Room

class_name BossRoom

@export var boss: Boss

func _ready() -> void:
	boss.room = self
	super._ready()

func desable():
	boss.desable()
	super.desable()
	
func enable():
	boss.enable()
	super.enable()

func _check_clear():
	return boss.is_dead
	
func switch_process(mode: bool):	
	super.switch_process(mode)
	boss.set_active(mode)
